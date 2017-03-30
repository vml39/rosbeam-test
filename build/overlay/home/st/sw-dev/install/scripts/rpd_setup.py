#! /usr/bin/env python

"""
usage: %prog [args]
"""

import os, sys
import struct, fcntl
from optparse import OptionParser
import subprocess
import tempfile
import threading
import re
import string
import json
import yaml
import base64
import tarfile
import StringIO
import time
import shutil
import random
from contextlib import contextmanager
from multi_interface_roam.netlink_monitor import IFSTATE
from stutil import sslopen, yaml_util
from stutil.bootcycle import Bootcycle
from stcommon.sanitize_hostname import sanitize_hostname
import traceback
import pwd
import socket
import xmlrpclib

import logging
import errno
from change_target import change_target, needs_upgrade, TransferInterruptedByProgressFunction

# NOMERGE
# - Test with texclient_permanent missing

# NOMERGE Dump all ping packets.

def set_default(dict, key, value):
  if key not in dict or not dict[key]:
    dict[key] = value

# FROM: http://stackoverflow.com/questions/106179/regular-expression-to-match-hostname-or-ip-address
addr_regex = re.compile(r"^(?P<host>(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))(:(?P<port>[0-9]+))?$")
host_regex = re.compile(r"^(?P<host>(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9]))(:(?P<port>[0-9]+))?$$")

to_prop_root = os.environ['TO_TEXCLIENT']
from_prop_root = os.environ['FROM_TEXCLIENT']

rpd_bin = os.environ['RPD_BIN']
rpd_scripts = os.environ['RPD_SCRIPTS']
rpd_resources = os.environ['RPD_RESOURCES']

def is_ip_port(s):
  return bool(addr_regex.match(s))

def is_listening(ip=None, port=None, proto=None):
  ##### Format IP #####
  if ip:
    ip_list = ip.split('.')[::-1]
    ip_regex = "{:02X}{:02X}{:02X}{:02X}".format(*map(int, ip_list))
  else:
    ip_regex = "[0-9A-F]{8}"

  ##### Format port #####
  if port:
    port_regex = "{:02X}{:02X}".format((port & 0xFF00) >> 8, port & 0x00FF)
  else:
    port_regex = "[0-9A-F]{4}"

  ##### Format state #####
  port_state = {
    'tcp':'0A',
    'udp':'07',
  }[proto]

  ##### Format regex #####
  final_regex = "\n\s+[0-9]+: {}:{} 00000000:0000 {}".format(ip_regex, port_regex, port_state)

  ##### Check for match #####
  try:
    port_matches = re.findall(final_regex, open("/proc/net/{}".format(proto), 'r').read())
    if port_matches:
      return True
  except:
    pass

  ##### No match or exception #####
  return False

def hostport(str, default_port=0):
  for reg in [addr_regex, host_regex]:
    m = reg.match(str)
    if m:
      if m.group('port'):
        return (m.group('host'), int(m.group('port')))
      else:
        return (m.group('host'), default_port)
  return None

def read_file(file_name):
  """Returns the content of file file_name."""
  with open(file_name) as f:
    return f.read()

def read_file_none_if_missing(file_name):
  """Returns the content of file file_name or None if it does not exist."""
  try:
    return read_file(file_name)
  except IOError as e:
    if e.errno != errno.ENOENT:
      raise
  return None

def write_file_unconditionally(file_name, content, is_binary=False):
    """Write a file even if it would not change. The write uses a rename to
    be atomic."""
    dir, fname = os.path.split(file_name)
    tmp_name = os.path.join(dir, "." + fname) # property monitor ignores files that start with a period
    with open(tmp_name, 'w') as f:
      if is_binary:
        f.write(content)
      else:
        f.write(content.encode('utf-8'))
    os.rename(tmp_name, file_name)

def write_file(file_name, content, is_binary=False):
    """Write a file only if it would change. Returns whether the file was saved."""
    if content != read_file_none_if_missing(file_name):
        write_file_unconditionally(file_name, content, is_binary)
        return True
    return False

options_test = False
def restart(reason="unknown"):
  # Give texclient a chance to restart us, then st-restart ourselves if necessary
  logging.info("Restarting for reason: %s"%reason)
  if not options_test:
      write_file(os.path.join(to_prop_root, 'st_restart_now'), reason)
      time.sleep(5)
      subprocess.check_call(['st-restart', reason])
  else:
      logging.info("Not actually restarting because of --test option.")
  sys.exit(0)

def get_texclient_property(name):
  """If texclient is running and the property exists return it. Otherwise
  return None."""
  try:
    prevmask = os.umask(0)
    with open('/var/lock/texclient', 'a') as f:
      lockdata = struct.pack('hhllhh', fcntl.F_WRLCK, 0, 0, 0, 0, 0)
      try:
        fcntl.fcntl(f, fcntl.F_SETLK, lockdata) # raises an IOerror if not successful
        return None # If we've reached this point, texclient is not alive.
      except IOError:
        try:
          return read_file(os.path.join(from_prop_root, name)).strip()
        except IOError:
          pass # Opening the file failed.
  finally:
    os.umask(prevmask)
  return None

def rpd_busy():
  # First check if in_use_until was set, regardless of whether texclient is running
  try:
    file_content = read_file(os.path.join(from_prop_root, 'in_use_until'))
    try:
      in_use_until_time = float(file_content)
    except ValueError:
      in_use_until_time = 0.0
    if in_use_until_time > time.time():
      return True
  except IOError:
    pass # Could not read the file.
  idle = get_texclient_property("idle")
  if idle is not None:
    try:
      return not bool(int(idle))
    except ValueError:
      pass

  # If there's any ambiguity other than an active texclient, holding th elock, with '0' in the idle file
  # we assume we're not busy to minimize the chances of ending up in a state where we can't upgrade
  return False

def in_call():
  num_sessions_in_progress = get_texclient_property("num_sessions_in_progress")
  if num_sessions_in_progress is not None:
    try:
      return bool(int(num_sessions_in_progress))
    except ValueError:
      pass
  # If there's any ambiguity other than an active texclient, holding th
  # elock, with '1' in the num_sessions_in_progress file we assume we're
  # not in a call to minimize the chances of ending up in a state where we
  # can't upgrade
  return False

multi_interface_roam_proxy = xmlrpclib.ServerProxy("http://localhost:7080/site_survey")
def write_multi_interface_roam_param(param, value, save = False):
  multi_interface_roam_proxy.set_site_survey_param(param, value)
  if save:
    multi_interface_roam_proxy.save_site_survey_config()

def is_multi_interface_roam_connected():
  interfaces = multi_interface_roam_proxy.get_interfaces()
  return any(interfaces[iface]['status'] >= IFSTATE.ADDR for iface in interfaces)

def set_multi_interface_roam_networks(networks):
  network_names = ', '.join(x['ssid'] for x in networks)
  logging.info("Networks checked: %s", network_names)
  res = multi_interface_roam_proxy.update_network_configuration(networks, True, True)
  if res['ERR_UPDATE_CONFIG_FAILED']:
    if res['ERR_FAILED_NETWORKS']:
      logging.error("Network configuration errors: {}".format(res['ERR_FAILED_NETWORKS']))
    logging.error("Network configuration failed for %s", network_names)
  else:
    multi_interface_roam_proxy.update_network_configuration(networks, True, False)
    logging.info("Networks applied: %s", network_names)
    multi_interface_roam_proxy.save_configuration()
    logging.info("Networks saved.")

def set_multi_interface_roam_ping_server(server_list, extra = False):
  if extra:
    # extra_base_station is written often (whenever rpd_setup refreshed is configuration)
    # there is no value in storing it on the disk
    param_name = "extra_base_station"
    save_param = False
  else:
    # base_station is written to disk so that if there is a multi_interface_roam restart
    # there is still a seed value (otherwise rpd_setup would need to be made aware that it
    # needs to keep pushing a base_station to multi_interface_roam)
    param_name = "base_station"
    save_param = True
  server_list_yaml = yaml.safe_dump(server_list)
  logging.info("Setting multi_interface_roam %s to: %s"%(param_name, server_list))
  write_multi_interface_roam_param(param_name, server_list_yaml, save = save_param)
  #if len(server_list):
    #logging.info("Sleeping for 1 seconds")
    #time.sleep(1) # Give multi_interface_roam time to get us stably connected before proceeding.

def get_multi_interface_roam_param(param):
  i = 0
  while True:
    try:
      return multi_interface_roam_proxy.get_site_survey_param(param)
    except Exception:
      if i == 0:
        print "Failed to get %s from multi_interface_roam. Retrying for 10 seconds."%param
      elif i == 10:
        raise
      time.sleep(1)
      i += 1

def set_system_check(name, message):
  write_file(os.path.join("/var/lib/st/system_check/", name), message)

@contextmanager
def open_atomic(name, mode=None, bufsize=None, permissions=None, uid=None, gid=None):
  """ Sets up a temp file and writes it once it closes """
  temp_file_path = os.path.dirname(name)
  temp_file_prefix = os.path.basename(name)
  with tempfile.NamedTemporaryFile(dir=temp_file_path, mode=mode, bufsize=bufsize, prefix=temp_file_prefix, delete=False) as temp_file:
    yield temp_file
  if permissions:
    os.chmod(temp_file.name, permissions)
  if uid or gid:
    os.chown(temp_file.name, uid or -1, gid or -1)
  os.rename(temp_file.name, name)

def ssh_setup_user(user, password_hash=None, authorized_keys=None, known_hosts=None):
  ##### Default Arguments #####
  authorized_keys = authorized_keys or []
  known_hosts = known_hosts or []

  try:
    ##### Set password #####
    if password_hash:
      subprocess.call(['usermod', '-p', password_hash, user])
  except Exception as e:
    print "Exception encountered setting password for user '{}':\n\t{} {}".format(user, e.message, e.args)

  try:
    ##### User information #####
    user_entry = pwd.getpwnam(user)
    user_dir = user_entry.pw_dir
    user_id = user_entry.pw_uid

    ##### Create .ssh directory if needed #####
    ssh_path = os.path.join(user_dir, ".ssh")
    if not os.path.isdir(ssh_path):
      os.makedirs(ssh_path)

    ##### Ensure correct permissions #####
    os.chmod(ssh_path, 0700)
    os.chown(ssh_path, user_id, user_id)

    try:
      ##### Authorized keys #####
      authorized_keys_list = []

      ##### Authorized Keys: Build List #####
      for key in authorized_keys:
        key_filepath = key[0]
        if not os.path.isfile(key_filepath) or not os.access(key_filepath, os.R_OK):
          print "Unable to read authorized_keys_list file '{}'".format(key_filepath)
          continue

        for key_hash in open(key_filepath, 'r').read().splitlines():
          if key_hash:
            authorized_keys_list.append((key_hash, key[1]))

      ##### Authorized keys: Write List #####
      with open_atomic(os.path.join(ssh_path, "authorized_keys"), 'wt', 0600, user_id, user_id) as f:
        for key in authorized_keys_list:
          f.write("{}\n".format(key[0]))
          f.write(",".join("{}=\"{}\"".format(option_name, option_value) for option_name,option_value in key[1].iteritems())+"\n")

    except Exception as e:
      print "Exception encountered building authorized list for user '{}':\n\t{} {}".format(user, e.message, e.args)

    try:
      ##### Known Hosts #####
      known_hosts_list = []

      ##### Known Hosts: Build List #####
      for address,key_filepath in known_hosts:
        if not os.path.isfile(key_filepath) or not os.access(key_filepath, os.R_OK):
          print "Unable to read known_hosts_list key file '{}'".format(key_filepath)
          continue

        for key in open(key_filepath, 'r').read().splitlines():
          if address and key:
            known_hosts_list.append((address,key))

      ##### Known Hosts: Write List #####
      with open_atomic(os.path.join(ssh_path, "known_hosts"), 'wt', 0600, user_id, user_id) as f:
        for host in known_hosts_list:
          f.write("{} {}\n".format(host[0], host[1]))

    except Exception as e:
      print "Exception encountered building known_hosts for user '{}':\n\t{} {}".format(user, e.message, e.args)

  except Exception as e:
    print "Exception encountered building SSH directory for user '{}':\n\t{} {}".format(user, e.message, e.args)

def ssh_start(start_spawner=True):
  def ssh_thread_func(spawner):
    ##### Host info #####
    infrastructure_address = "[localhost]:6822,[127.0.0.1]:6822"
    infrastructure_keyfile = os.path.join(rpd_resources, "infrastructure_key.pub")
    outer_address = "[localhost]:2222,[127.0.0.1]:2222"
    outer_keyfile = "/home/st/outer_host.pub"

    ##### Hosts #####
    host_infrastructure = (infrastructure_address, infrastructure_keyfile)
    host_outer = (outer_address, outer_keyfile)

    ##### Key info #####
    outer_address = "127.0.0.1"
    texbuild_address = "127.0.0.1"
    developer_address = texbuild_address
    support_address = "127.0.0.1"
    if os.path.exists("/store/config/wifi_dev_mode"):
      developer_address += ",192.168.68.2"
    developer_keyfile = os.path.join(rpd_resources, "developer_key.pub")
    outer_keyfile = "/home/st/outer_key.pub"
    support_keyfile = os.path.join(rpd_resources, "support_key.pub")
    texbuild_keyfile = os.path.join(rpd_resources, "texbuild_priv_key.pub")

    ##### Keys #####
    key_developer = (developer_keyfile, {"from":developer_address})
    key_outer = (outer_keyfile, {"from":outer_address})
    key_support = (support_keyfile, {"from":support_address})
    key_texbuild = (texbuild_keyfile, {"from":texbuild_address})

    ##### Setup each user #####
    ssh_setup_user(
      'root',
      None,
      authorized_keys = [key_developer, key_texbuild],
      known_hosts = [host_infrastructure, host_outer]
    )
    ssh_setup_user(
      'st',
      '$6$rounds=5000$Z/pRC8Pia6f/AA64$yzeB1EQD8gR70kicAs1/uP8FxUDOCPJGuEadd/bx1V7TxkYXyseBbPHIw2VoZ0xNTnkKwoa1132Y0cYyP4Ppn/',
      authorized_keys = [key_developer, key_outer, key_support, key_texbuild],
      known_hosts = [host_infrastructure]
    )

    ##### Setup SSH privilege separation directory #####
    ssh_privsep_path = "/var/run/sshd"
    if not os.path.isdir(ssh_privsep_path):
      os.mkdir(ssh_privsep_path, 0755)

    ##### Start SSH #####
    logging.info("Starting inner SSH server...")
    subprocess.call(['start-stop-daemon', '--start', '--quiet', '--oknodo', '--pidfile', '/var/run/sshd.pid', '--exec', '/usr/sbin/sshd'])
    if spawner:
      logging.info("Starting SSH spawner...")
      subprocess.call(['start-stop-daemon', '--start', '--background', '-m', '--pidfile', '/var/run/sshspawner.pid', '-a', os.path.join(rpd_scripts, 'sshspawner')])

  ##### Launch it #####
  ssh_thread = threading.Thread(target=ssh_thread_func, args=(start_spawner,))
  ssh_thread.start()

  ##### Return #####
  return ssh_thread

config_relay_log_file = os.path.join(os.environ.get('STLOG', '/var/log/st'), 'config_relay.log')

class Relay(object):
  def __init__(self, relaybin, relayserver, tcp_forwards, udp_forwards, relay_port = None, log_file = None):
    relay_config = {
            'tcp_forwards' : [ { 'from': port, 'to': "%s@%s"%(resource,relayserver) } for (port, resource) in tcp_forwards ],
            'udp_forwards' : [ { 'from': port, 'to': "%s@%s"%(resource,relayserver) } for (port, resource) in udp_forwards ],
            }
    if relay_port is not None:
      relay_config['relay_ports'] = { 'main': relay_port }

    logging.info("Bringing up relay to %s"%relayserver)
    for port, resource in tcp_forwards:
      logging.info(" - tcp: %s -> %s"%(port, resource))
    for port, resource in udp_forwards:
      logging.info(" - udp: %s -> %s"%(port, resource))

    cmd = [relaybin, '-t', 'relay_config=%s'%(yaml.safe_dump(relay_config))]
    if log_file is None:
      self.relay_proc = subprocess.Popen(cmd)
    else:
      with open(log_file,'a') as relay_log:
        self.relay_proc = subprocess.Popen(cmd, stdout=relay_log, stderr=relay_log)

    #Wait for relay to come up
    maxwait = time.time() + 5
    with open('/dev/null', 'a') as devnull:
      def wait_for_listen(port, proto):
        # Note: check isn't tight if not bound to an interface. Should be
        # fine unless you try to bind both to any address and to a specific
        # one.
        port_str = "@" + port if type(port) != int else ":%d"%port
        state = [ '-s', "TCP:LISTEN" ] if proto == "TCP" else []
        cmd = ['lsof', '-n', '-a', '-p', str(self.relay_proc.pid), '-i', proto+port_str ] + state
        while (subprocess.call(cmd, stdout=devnull, stderr=devnull) != 0):
          if (time.time() > maxwait):
            logging.warning("Maximum wait exceeded while waiting for relay on %s"%port_str)
            break
          time.sleep(.1)

      for port,_ in tcp_forwards:
        wait_for_listen(port, "TCP")

      for port,_ in udp_forwards:
        wait_for_listen(port, "UDP")

  def shutdown(self):
    if self.relay_proc:
      logging.info("Bringing down relay")
      try:
        if self.relay_proc.poll() is None:
          self.relay_proc.terminate()
      except OSError:
        logging.warn("Unable to terminate relay.")
      self.relay_proc.wait() # Avoid leaving a zombie around
      self.relay_proc = None

  def is_running(self):
    return self.relay_proc is not None and self.relay_proc.poll() is None

class RpdSetup(object):
  store_root = '/store/config'
  prop_name = os.path.join(to_prop_root, 'rpd_name')
  prop_requires_unlink = os.path.join(to_prop_root, 'requires_unlink')
  prop_username = os.path.join(to_prop_root, 'username')
  store_name = os.path.join(store_root, 'rpd_name')
  developer_mode_rpd_prop = os.path.join(to_prop_root, 'developer_mode_rpd')
  upgrading_prop = os.path.join(to_prop_root, 'upgrading')
  upgrading_percent_prop = os.path.join(to_prop_root, 'upgrading_percent')
  upgrading_restart_request_prop = os.path.join(to_prop_root, 'upgrading_restart_request')
  prop_last_updated = os.path.join(to_prop_root, 'last_updated_from_infrastructure')
  watchdog_prop = os.path.join(to_prop_root, 'watchdog_rpd_setup')
  release_id_prop = os.path.join(to_prop_root, 'release_id')

  # Config server files
  config_server_root = os.path.join(store_root, 'config_server')
  texclient_config_server_file = os.path.join(store_root, 'texclient_permanent', 'config_servers')
  redirect_config_server_file = os.path.join(config_server_root, 'redirect')
  default_config_servers_file = os.path.join(rpd_resources, 'default_config_servers')
  cached_config_server_file = os.path.join(config_server_root, 'cached')

  def __init__(self, relaybin, cert):
    self.config = None
    self.relaybin = relaybin
    self.cert = cert
    self.chrony_threads = {}
    self.texclient_config_servers = []

    try:
      self.current_release = yaml.load(read_file('/var/st/running'), Loader=yaml_util.MostlySafeLoader)
    except Exception:
      logging.warning("Could not read /var/st/running")
      self.current_release = {}

    if 'release_id' in self.current_release:
      write_file(self.release_id_prop, self.current_release['release_id'])

  def load(self):
    """Determines the config servers, and loads the configuration."""
    config_servers = self.get_config_servers()
    out = self._load_from_server_list(config_servers, set(), [], set())
    return out

  def _load_from_server_list(self, servers, attempted_servers, all_servers, all_addresses):
    """Loads the config from one of the servers in the list."""

    # Add the new servers to the list of all available servers, and tell
    # multi_interface_roam about them.
    added = False
    for s in servers:
      addr = s['address']
      if addr is not None and addr not in all_addresses:
        all_servers.append(s)
        all_addresses.add(addr)
        added = True
    if added:
      set_multi_interface_roam_ping_server(all_servers, extra = True)

    if not is_multi_interface_roam_connected():
      logging.info("No network connection exists, skipping.")
      return

    # Servers must be attempted in order to match the priority order
    # returned by get_config_servers().
    for srv in servers:
      try:
        if self._load_from_server(srv, attempted_servers, all_servers, all_addresses):
          return True
      except Exception:
          logging.error("Exception loading configuration from server: %s"%srv)
          logging.error(traceback.format_exc())

  def _load_from_server(self, server, attempted_servers, all_servers, all_addresses):
    """Loads the configuration from a server.

    server is of the form: { "address": "1.2.3.4:1234", ... }
    It is okay to throw, as the caller will catch all exceptions and move
    on to the next candidate.
    """

    logging.info("")
    logging.info("Attempting to load configuration from %s"%server)

    server_address = server["address"]

    # Don't do a server more than once per call to load().
    if server_address in attempted_servers:
      logging.info("Already tried this server, skipping.")
      return False
    attempted_servers.add(server_address)

    hp = hostport(server_address)
    if hp is None:
      logging.warning("Address '%s' is not in host:port format."%server_address)
      return False

    # Handle the case where we need to do a DNS lookup.
    # This relies on the following multi_interface_roam features:
    #
    # 1. If no base_station or extra_base_station is set then
    # multi_interface_roam defaults to disable_ping_timeout mode.
    #
    # 2. If no base_station or extra_base_station is set then
    # multi_interface_roam selects the DHCP dns servers.
    #
    # If the Beam has been connected since st-restart but all the relays
    # have disappeared then base_station will not be empty and DNS lookup
    # will fail. However, after 30 minutes the Beam will watchdog, and upon
    # restarting should successfully connect. This is acceptable because
    # this scenario should effectively never occur. I have opened TOPS-79
    # to make sure that the DNS lookup case gets testing. Otherwise it is
    # certain to regress eventually.
    if not is_ip_port(server_address):
      logging.info("Trying to DNS lookup %s"%server_address)
      results = socket.getaddrinfo(hp[0], None, socket.AF_INET, socket.SOCK_DGRAM)
      addresses = [ r[4][0] for r in results ]
      logging.info("Found: %s"%", ".join(addresses))
      addresses = [ { "address": addr + ":%i"%hp[1] } for addr in addresses ]
      return self._load_from_server_list(addresses, attempted_servers, all_servers, all_addresses)
    relay = None
    try:
      udp_forwards = [("127.0.1.1:123", 'ntp')] # Don't want to interfere with the relayspawner relay on 127.0.0.1
      relay = Relay(self.relaybin, server_address, [('127.0.0.1:8888', 'config_ssl')], udp_forwards, 6801, log_file = config_relay_log_file)

      set_multi_interface_roam_ping_server(all_servers, extra = True)

      params = {
          'format': 'json',
          'relay_autodetect': '1',
          }
      if 'release_id' in self.current_release:
        params['release_id'] = str(self.current_release['release_id'])

      url = 'https://local-infr-relay.suitabletech.com:8888/api/2/device_configuration/'
      logging.info("Retrieving config from: %s"%url)
      try:
        f = sslopen.sslopen(url, cert=self.cert, verify=True, params=params)
      except sslopen.SSLOpenSSLError, e:
        logging.error("SSLError: %s"%e)
        set_system_check("ssl_error", "Config server SSL certificate could not be verified: %s"%e)
        # One reason why we might get an SSL error is if the time is not
        # synchronized. So try to synchronize the time. Assume that all the
        # servers have a roughly correct time so we only do this if we have
        # never done a successful time sync.
        self.synchronize_time('127.0.1.1', i_block=True, i_force=True)
        return False

      self.config = json.loads(f)

      if type(self.config) is list:
        if len(self.config) > 1:
          logging.warning("Received multiple configurations from server.  Don't know which one to use.")
          return False
        elif len(self.config) == 0:
          logging.warning("Server had no configuration for uid")
          return False
        else:
          self.config = self.config[0]

      if relay:
        relay.shutdown()


      need_redirect = False
      # Old style redirection
      redirect = self.config.get('redirect', None)
      if redirect:
        logging.info('Old style redirection to %s'%redirect)
        redirect_to = [ redirect["relay"] ]
        permanent_redirect = redirect.pop('permanent', False)
        need_redirect = True

      # New style redirection:
      # - If the current server is not in the list of relays then redirect.
      # - Store the relays if permanent_redirect is set.
      else:
        redirect_to = self.get_relay_servers()
        permanent_redirect = self.config.get('permanent_redirect', False)
        relay_server_addresses = [ r.get('address') for r in redirect_to ]
        if relay_server_addresses and (server_address not in relay_server_addresses):
          logging.info('New-style redirection to %s'%redirect_to)
          need_redirect = True

      # If there is not a redirection, and we have no specified relay servers,
      # return True only if we have a pairing key.  Otherwise, return False
      # so that we try the next server.
      if not need_redirect and not self.get_relay_servers():
        if self.config.get('pairing_key'):
          return True
        elif self.config.get('claim_key'):
          return True
        else:
          logging.warning("server_address: %s provided no relays"%server_address)
          return False

      # Store these relays as permanent if appropriate.
      if permanent_redirect:
        if write_file(self.redirect_config_server_file, yaml.safe_dump(redirect_to, default_flow_style=False)):
          logging.info("Saved permanent redirection to %s"%redirect_to)
        else:
          logging.info("Permanent redirection does not change state.")

      # Redirect if needed
      if need_redirect:
        random.shuffle(redirect_to) # Avoid everybody hitting the same server first.
        return self._load_from_server_list(redirect_to, attempted_servers, all_servers, all_addresses)

      return True
    except Exception, e:
      logging.warning("Exception: %s\n%s"%(e, traceback.format_exc()))
      return False
    finally:
      if relay:
        relay.shutdown()

  def synchronize_time(self, i_host, i_block=False, i_force=False):
    # If we stepped back more than 5 seconds, we are just going to restart.  This is
    # probably excessive but keeps us from having to deal with any significant jumps.

    if in_call():
      return # Ensure that relayspawner isn't stuck on an old relay.

    logging.info("chrony: Configuring synchronization with {}".format(i_host))
    attempt_timeout = 30
    attempt_start = os.times()[4]
    while (os.times()[4] - attempt_start) < attempt_timeout:

      ##### Check port #####
      if not is_listening(ip=i_host, port=123, proto='udp'):
        time.sleep(0.1)
        continue

      host_detected = False
      CHRONY_PATH = '/usr/sbin/chronyd'
      if subprocess.call(['pgrep', '-fx', CHRONY_PATH]):
        # Kill all threads
        self.chrony_threads = {}

        # Create chrony command access key
        logging.info("chrony: Creating access key")
        chrony_keys_filepath = os.path.join(os.sep, 'etc', 'chrony', 'chrony.keys')
        if not os.path.exists(chrony_keys_filepath):
          with open(chrony_keys_filepath, 'wt') as chrony_keys_file:
            key = ''.join(random.choice(string.ascii_letters + string.digits) for x in range(63))
            chrony_keys_file.write('1 {0}\n'.format(key))

        # Start chrony
        logging.info("chrony: Starting daemon")
        subprocess.Popen(['start-stop-daemon', '--start', '--verbose', '--exec', CHRONY_PATH])

        # Wait for chronyd to start listening
        while (os.times()[4] - attempt_start) < attempt_timeout:
          if is_listening(ip='127.0.0.1', port=323, proto='udp'):
            break
          time.sleep(0.1)

        logging.info("chrony: Daemon ready")

      ##### Delete all non-current sources #####
      for source in self.chrony_threads.keys():
        if i_host != source or i_force:
          logging.info("chrony: Removing {}".format(source))
          del self.chrony_threads[source]
          subprocess.Popen(['chronyc', '-a', 'delete', source])
        else:
          host_detected = True

      ##### Add current source #####
      if not host_detected:
        logging.info("chrony: Adding {}".format(i_host))
        subprocess.Popen(['chronyc', '-a', 'add server '+i_host])
        subprocess.Popen(['chronyc', '-a', 'burst 3/10'])

        def makestep_thread_func(i_host):
          chrony_synchronized = False
          while i_host in self.chrony_threads and self.chrony_threads[i_host] == threading.currentThread() and not chrony_synchronized:
            try:
              # Wait 20 seconds for clock to be within 5 seconds of accurate
              chrony_waitsync_start = time.time()
              subprocess.check_call(['chronyc', '-a', 'waitsync 2 5'])
              chrony_waitsync_stop = time.time()
              chrony_synchronized = True
            except subprocess.CalledProcessError as e:
              continue

            # Force the clock forward if adjustment is larger than 2 seconds in the first 10 clock updates
            chrony_makestep_start = time.time()
            subprocess.check_call(['chronyc', '-a', 'makestep 2 10'])
            chrony_makestep_stop = time.time()

            delta = min(chrony_makestep_stop-chrony_makestep_start, chrony_waitsync_stop-chrony_waitsync_start)

            Bootcycle().event('clockstep', {'delta': delta})

            if (delta < -5):
              logging.warning("Had to step time backwards.  Restarting")
              # This is heavy handed, but safe for now
              restart("Time stepped backwards")

          if chrony_synchronized:
            logging.info("chrony: Synchronized to {}".format(i_host))

        # Start thread
        makestep_thread = threading.Thread(target=makestep_thread_func, args=(i_host,))
        self.chrony_threads[i_host] = makestep_thread
        makestep_thread.start()
        logging.info("chrony: Added {}".format(i_host))

        if i_block:
          logging.info("chrony: Waiting for synchronization of {}".format(i_host))
          makestep_thread.join(attempt_timeout - (os.times()[4] - attempt_start))

      ##### Reset system check and return true #####
      set_system_check("ntp_error", "")
      return True

    ##### Failed, provide error #####
    if not i_block:
      # Only bother warning about errors on the final NTP relay server as
      # errors on the config server are more likely to happen transiently
      # at startup.
      set_system_check("ntp_error", "NTP failed")

  def get_relay_servers(self):
    # Sanitize relays. We don't allow any host names coming from the
    # server as there is no reason to use them server-side, and that
    # could cause trouble in multi_interface_roam. If we want to specify
    # hostnames on the server, then it is up to the server to do DNS
    # lookup for us while processing our request for configuration.

    # Add self.texclient_config_servers so that you can use a local relay
    # simply by setting a custom config server in the Beam's config UI.

    # For backwards-compatibility reasons, relay_servers (explicitly specified
    # for a beam) and default_relay_servers (globally available for any beam)
    # get served separately.
    relays = self.texclient_config_servers + self.config.get('relay_servers', []) + self.config.get('default_relay_servers', [])
    def check_relay(relay):
      addr = relay.get("address", "")
      if is_ip_port(addr):
        return True
      logging.warn('Relay has non ip:port address. Skipping it. %s'%relay)
      return False

    return filter(check_relay, relays)


  def run(self):
    if not self.config:
      return False

    # Store the relays in the cache.
    write_file(self.cached_config_server_file, yaml.safe_dump(self.get_relay_servers(), default_flow_style = False))

    # store the pairing key in the property system
    pairingkey_prop = os.path.join(to_prop_root, 'pairing_key')
    write_file(pairingkey_prop, self.config.get('pairing_key', ""))

    # pass the claim key to the property system
    claimkey_prop = os.path.join(to_prop_root, 'claim_key')
    write_file(claimkey_prop, self.config.get('claim_key', ""))

    if 'vpn_cert' in self.config:
      try:
        vpn_cert_string = base64.b64decode(self.config['vpn_cert'])
        vpn_cert_io = StringIO.StringIO(vpn_cert_string)
        vpn_tgz = tarfile.open(fileobj=vpn_cert_io)
        vpn_tgz.extractall(path="/etc/wg-openvpn")
      except Exception, e:
        logging.error("Problem applying vpn cert: %s"%e)

    dhcp_hostname = ""
    if 'hostname' in self.config:
      dhcp_hostname = self.config['hostname']
      write_file('/etc/hostname', self.config['hostname'])
      subprocess.call(['hostname', '-F', '/etc/hostname'])

#70.35.57.198 fws.suitabletech.com
      write_file('/etc/hosts', """
127.0.0.1 localhost local-infr-relay.suitabletech.com crash.suitabletech.com %s

192.168.68.2 rpal-thinkpad.local
# The following lines are desirable for IPv6 capable hosts

::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
"""%self.config['hostname'])

    if 'device' in self.config:
      write_file('/var/lib/st/username', self.config['device']['username'])
      write_file('/var/lib/st/password', self.config['device']['password'])
      write_file(RpdSetup.store_name, self.config['device']['name'])
      write_file(RpdSetup.prop_name, self.config['device']['name'])
      write_file(RpdSetup.prop_requires_unlink, '1' if self.config.get('is_manufacturing', False) else '0')
      write_file(RpdSetup.prop_username, self.config.get('hostname', ''))

      # NCA-3874: If there is a user-visible name for the device, use that as
      # the DHCP name.
      dhcp_hostname = self.config['device']['name']

    # Leave room for a _wlanX suffix and still fit in 63 characters.
    dhcp_hostname = sanitize_hostname(dhcp_hostname, 63 - len("_wlanX"))

    # Set the hostname that multi_interface_roam will use in dhcp requests.
    # It is saved to disk so that when you first do dhcp, before
    # getting configuration, you still have the cached dhcp_hostname from
    # the previous run of multi_interface_roam. Without this, when all goes
    # well (i.e., you do a single DHCP at startup) the host name would only
    # show up for beams that have had to renew their leases.
    write_multi_interface_roam_param('dhcp_hostname', dhcp_hostname, save = True)

    # NCA-8173 Don't restrict to single adapter in manufacturing test.
    single_adapter_lock = not self.config.get('dual_radio_enabled') and not self.is_test_mode()
    write_multi_interface_roam_param('single_adapter_lock', single_adapter_lock, save = True)

    set_multi_interface_roam_ping_server(self.get_relay_servers())

    write_file('/var/lib/st/sshport', str(self.config.get('ssh_port',0)))
    write_file('/var/lib/st/httpport', str(self.config.get('http_port',0)))

    if 'camera_calibration' in self.config:
      try:
        cal = base64.b64decode(self.config['camera_calibration'])
        write_file('/store/config/rpd.cal', cal, True)
      except Exception, e:
        logging.error("Problem applying calibration: %s"%e)

    if 'base_calibration' in self.config:
      try:
        cal = base64.b64decode(self.config['base_calibration'])
        write_file('/store/config/base_calibration.cal', cal, True)
      except Exception, e:
        logging.error("Problem applying base calibration: %s"%e)

    if 'ptz_calibration' in self.config:
      try:
        cal = base64.b64decode(self.config['ptz_calibration'])
        write_file('/store/config/ptz_calibration.cal', cal, True)
      except Exception, e:
        logging.error("Problem applying ptz calibration: %s"%e)

    test_mode = self.is_test_mode()
    write_file('/var/lib/st/test_mode', str(int(test_mode)))
    if not test_mode:
      subprocess.call(['pkill', '-x', 'rpd_test_server'])

    developer_mode = self.is_developer_mode()
    for name in ['/var/lib/st/developer_mode', self.developer_mode_rpd_prop]:
      write_file(name, str(int(developer_mode)))

    if developer_mode:
      logging.info("Developer mode active. Configuring SSH...")
      ssh_start(start_spawner=True)
      # Starting to service the watchdog so we don't get power cycled if
      # texclient isn't running.
      subprocess.Popen(['start-stop-daemon', '--start', '--background', '-m', '--pidfile', '/var/run/hardware_watchdog_tickler.pid', '-a',
          os.path.join(rpd_bin, 'st001_power_control'), 'W', '/dev/st001', '300', '5'])

    # trigger this through the property change listener
    configkey_prop = os.path.join(to_prop_root, 'configuration_key')
    write_file(configkey_prop, str(time.time()))

    self.update_last_updated_time()
    return True

  def is_test_mode(self):
    # If test mode is not specified, default to True only if this is a manufacturing image
    default_test_mode = os.path.exists('/var/lib/st/manufacturing')
    test_mode = bool(self.config.get('test_mode', default_test_mode))
    return test_mode

  def is_manufacturing(self):
    return os.path.exists('/var/lib/st/manufacturing')

  def is_developer_mode(self):
      return bool(self.config.get('developer_mode', False))

  def do_upgrade_if_necessary(self):
    # We do not upgrade if:
    # - We are in head pilot station mode and test_mode is set
    # - We are in developer mode and: Running a developer image OR no_developer_upgrade is set on the SD card
    # - We are in a call
    # - We are running the correct version.
    # - The release_id is "NO_UPGRADE" or empty/not set.

    # We (RPAL) change this to prevent upgrades from ever triggering
    upgrade_release_id = 'NO_UPGRADE'
    self.software_update_system_check = ""
    ready_to_restart = False
    if upgrade_release_id and upgrade_release_id != 'NO_UPGRADE' and needs_upgrade(upgrade_release_id):
      # We are not running the desired version. Now check various reasons
      # not to restart.
      if in_call():
        logging.info("Not upgrading because we are in a call")
        # Preserve current value of system check in this case.
        self.software_update_system_check = None
      elif self.is_test_mode() and os.path.exists("/store/config/HPS_CLIENT_MODE"):
        logging.info("Not upgrading because test_mode is true and /store/config/HPS_CLIENT_MODE exists.")
      elif self.is_developer_mode() and (os.path.exists("/var/lib/st/developer") or os.path.exists("/store/config/no_developer_upgrade")):
        logging.info("Not upgrading because developer_mode is true and /var/lib/st/developer or /store/config/no_developer_upgrade exists.")
      else:
        # If we got here, then we are not running the right version, and
        # there is no reason for us not to be upgrading.
        ready_to_restart = self.do_upgrade(upgrade_release_id) # May set self.software_update_system_check

    # Make it easy to see what we are telling texclient!
    logging.info("ready_to_restart=%i software_update_system_check='%s' rpd_busy()=%i"%
            (ready_to_restart, self.software_update_system_check, rpd_busy()))

    # Set the software_update system check.
    if self.software_update_system_check is not None:
      set_system_check("software_update", self.software_update_system_check)

    if not ready_to_restart:
      write_file(self.upgrading_restart_request_prop, "0")
      write_file(self.upgrading_prop, "0")
      return

    # Let texclient know if it should be restarting us.
    write_file(self.upgrading_restart_request_prop, "1")

    # Give texclient a chance to show that we've finished downloading
    # and are about to restart
    time.sleep(5)

    # The desired version is ready to go. We want to switch to it.
    # Texclient should be restarting us, but if the beam is idle for 10
    # seconds then texclient may be dead and we should initiate the
    # shutdown.
    restart_time = time.time() + 10
    logging.info("Need to restart to new release. Giving texclient 10 seconds to restart us.")
    while not rpd_busy():
      if time.time() > restart_time:
        restart("Texclient is not restarting us, rpd_setup will!")
      time.sleep(1)

    # Tell beam to no longer indicate that it is upgrading
    # (Do it here rather than in do_upgrade in case rpd_setup is restarted.)
    write_file(self.upgrading_prop, "0")

  def do_upgrade(self, upgrade_release_id):
    logging.info("Upgrade to %s requested. Currently at %s."%(upgrade_release_id, self.current_release.get('release_id',"<unknown>")))

    relay = None
    try:
      # Figure out which relay to use to do the transfer, and bring up a
      # relay to it.
      retries = 0
      while True:
        best_relay = get_multi_interface_roam_param('best_relay')
        if best_relay:
          break
        if retries == 0:
          logging.info("Waiting up to 20 seconds for multi_interface_roam to select a relay.")
        elif retries >= 20:
          self.software_update_system_check = "Timed out waiting for multi_interface_roam to select relay."
          return False
        time.sleep(1)
        retries += 1
      logging.info("Using relay %s for download."%best_relay)
      relay = Relay(self.relaybin, best_relay,
          [('127.0.0.1:8990', 'releases_ssl')], [], 6802, log_file = config_relay_log_file)

      # When count == 0 we do a dry run to cheaply check that the upgrade is
      # likely to succeed. Then on subsequent iterations we actually try
      # to upgrade.
      for dry_run in ( True, False ):
        def progress(completed, total):
          now = time.time()
          if now > progress.last_update + 0.1:
            # NCA-5204 rpd_setup's watchdog needs to be tickled while downloading
            # or else it will get restarted by texclient if the download takes too long
            write_file(self.upgrading_percent_prop, str(100 * completed/float(total)))
            self.tickle_watchdog()
            progress.last_update = now
          if in_call():
            logging.info("Beam is in a call. Interrupting transfer.")
            return True
        progress.last_update = 0

        # Mark the beam as upgrading on the first non-dry run.
        if not dry_run:
          progress(0, 1) # clears upgrading_percent_prop before setting upgrading_prop
          write_file(self.upgrading_prop, "1")
          logging.info("Upgrading release to: %s"%upgrade_release_id)

        if change_target(upgrade_release_id, cert=self.cert, do_cleanup=True, dry_run=dry_run, progress = progress):
          if not dry_run:
            progress(1, 1) # set percent to 100 in case we missed the last callback
            logging.info("Software upgrade success.")
            return True
        else:
          self.software_update_system_check = "change_target unexpectedly returned False"
          return True
    except TransferInterruptedByProgressFunction:
      logging.info("Transfer interrupted")
    except Exception, e:
      logging.error("Problem in do_upgrade: %s"%e)
      logging.error(traceback.format_exc())
      self.software_update_system_check = "Software update failure: %s"%e
    finally:
      if relay:
        relay.shutdown()

    logging.info("Upgrade deferred")
    return False

  def update_last_updated_time(self):
    update_time = '%d' % int(time.time())
    write_file(RpdSetup.prop_last_updated, update_time)

  def tickle_watchdog(self):
    """rpd_setup ticlkes this watchdog each time it successfully completes
    all its work. This watchdog is monitored by texclient. The goal is to
    allow a faster restart (and rollback) if rpd_setup is broken in a way
    that prevents it from fetching and running its configuration."""
    write_file(RpdSetup.watchdog_prop, str(time.time()))

  def load_config_server_file(self, filename, allow_nonlist = False):
    """Format must be: [ { address: "ip1:host1" }, { addres: "ip2:host2" } ]"""
    try:
      raw_file = read_file(filename)
    except Exception:
      logging.warning("Could not read %s"%filename)
      return []
    try:
      out = yaml.load(raw_file, Loader=yaml_util.MostlySafeLoader)
    except Exception:
      logging.warning("Could not parse %s"%filename)
      return []

    if type(out) is not list:
      if allow_nonlist:
        return out
      else:
        logging.warning("%s did not contain a list."%filename)
        return []

    random.shuffle(out) # Avoid having everybody hit the same server first.
    return out

  def load_texclient_config_server_file(self):
    """Format is space separated list of ip:host. Should be validated by texclient."""
    addresses = read_file_none_if_missing(self.texclient_config_server_file)
    if addresses is None:
        logging.warning("texclient config_server file missing")
        return []
    addresses = addresses.split()
    addresses = [ { "address": addr } for addr in addresses ]
    return addresses

  def get_config_servers(self):
    """
    Gets a list of all the relevant config servers, sorted in priority
    (highest priority first). The sources are:

    - /store/config/texclient_permanent/config_servers  # Configured by the user in the UI
    - /store/config/config_server/redirect              # Written when a redirection happens
    - <rpd_resources>/default_config_servers            # Default
    - /store/config/config_server/cached                # Most recent set of relays

    Some servers may appear multiple times in the list returned here. The
    consumers of this list (RpdSetup.load() and multi_interface_roam are
    responsible for eliminating duplicates).
    """

    self.texclient_config_servers = self.load_texclient_config_server_file()
    redirect = self.load_config_server_file(self.redirect_config_server_file)
    default = self.load_config_server_file(self.default_config_servers_file)
    cached = self.load_config_server_file(self.cached_config_server_file)
    return self.texclient_config_servers + redirect + default + cached

def main(argv, stdout, environ):

  logging.basicConfig(format="rpd_setup.py: %(asctime)s:[%(module)s] %(message)s", level=logging.INFO)

  parser = OptionParser(__doc__.strip())
  parser.add_option("--cert", action="store", type="string", dest="cert",default='/store/config/device.pem',
                    help="File containing the device certificate")
  parser.add_option("--relay", action="store", type="string", dest="relaybin",default=os.path.join(rpd_bin, 'beam_relay'),
                    help="Path to the relay binary")
  parser.add_option("--test", action="store_true", dest="test",default=False,
                    help="Run test")

  (options, args) = parser.parse_args()

  if (len(args) != 0):
    parser.error("rpd_setup.py doesn't take any arguments")

  global options_test
  options_test = options.test

  logging.info("")
  logging.info("Starting rpd_setup.py...")
  logging.info("========================")

  if not os.path.isdir('/var/lib/st'):
    os.makedirs('/var/lib/st')

  if not os.path.exists(options.cert):
    parser.error("Certificate: %s does not exist"%options.cert)

  setup = RpdSetup(options.relaybin, options.cert)

  if not os.path.isfile(RpdSetup.prop_name) and os.path.isfile(RpdSetup.store_name):
    shutil.copy(RpdSetup.store_name, to_prop_root)

  set_system_check("software_update", "")
  set_system_check("ntp_error", "")
  set_system_check("ssl_error", "")

  # NCA-2779: Nothing kills beam_relay when rpd_setup goes down, which can
  # get you stuck in a state where rpd_setup can't start a relay to the
  # config server. The pkill below is excessive because it kills the
  # relayspawner relay also. But rpd_setup isn't supposed to die during
  # normal use so this is okay.
  logging.info("Killing any running beam_relay processes.")
  subprocess.call(['pkill', '-x', 'beam_relay'])

  current_yaml_name = '/var/lib/st/current.yaml'
  try:
    current_config = yaml.load(file(current_yaml_name, 'r'), Loader=yaml_util.MostlySafeLoader)
    have_config = True
  except:
    logging.warning("Could not load %s, assuming we are just out of st-restart"%current_yaml_name)
    current_config = {}
    have_config = False
    set_multi_interface_roam_ping_server([]) # Don't keep ping servers from previous st-restart

  needs_deferred_restart = None

  while True:
    if have_config:
      logging.info("Checking if config has changed...")
    else:
      logging.info("Trying to fetch initial config.")

    if needs_deferred_restart and not rpd_busy():
      restart(needs_deferred_restart)

    if setup.load():
      set_multi_interface_roam_ping_server([], extra = True)
      logging.info("")
      logging.info("Configuration loaded. Applying it...")
      set_system_check("ssl_error", "")

      # Figure out the set of critical keys.
      if 'pairing_key' in current_config:
        critical_keys = []
      else:
        critical_keys = ['test_mode']
      # If the incoming config is not in developer mode, then developer mode is
      # considered critical as long as the key was there previously => We always
      # restart when leaving developer mode.
      if not setup.config.get('developer_mode', False) and 'developer_mode' in current_config:
        critical_keys.append('developer_mode')
      if not have_config or setup.config != current_config:
          logging.info("Got new config: %s"%setup.config)
      all_keys = set(current_config.keys() + setup.config.keys())

      # Restart if any critical keys have changed, and build up the set of
      # modified keys.
      mismatch = []
      for k in all_keys:
        if current_config.get(k) != setup.config.get(k):
          mismatch.append(k)
          if k in critical_keys and have_config:
            msg = "Configuration change on critical key: %s"%k
            logging.info(msg)
            if not rpd_busy():
              restart(msg)
            else:
              needs_deferred_restart = msg

      # Run other work if something has changed
      if mismatch or not have_config:
        logging.info("mismatch keys: %s"%(mismatch,))
        if setup.run():
          if 'networks' in mismatch:
            set_multi_interface_roam_networks(yaml.safe_load(setup.config.get('networks')))
          if 'ssh_port' in mismatch or 'http_port' in mismatch:
            subprocess.call(['pkill', '-x', 'ssh'])
          if 'relay_servers' in mismatch:
            # Changed the set of relay servers, make sure we are
            # synchronized with one of the new relays.
            setup.synchronize_time('127.0.0.1', i_force=True)
          logging.info("Successfully loaded and ran configuration.")
          if options.test:
              sys.exit(0)
        else:
          logging.info("Failure to run setup.  Restarting")
          if options.test:
              sys.exit(1)
          restart("Setup failed")
      else:
        setup.update_last_updated_time()

      # Check if an upgrade is needed
      # NCA-5216 This must happen after setup.run()
      # so that multi_interface_roam will have chosen
      # a relay to use for the download
      setup.do_upgrade_if_necessary()

      # Write the new config to disk if it has changed.
      if not options.test and current_config != setup.config:
        write_file(current_yaml_name, yaml.safe_dump(setup.config))

      if options.test:
         logging.info("Successfully loaded configuration. No action was needed.")
         sys.exit(0)

      current_config = setup.config.copy()
      have_config = True

      # In case the time sync has failed, do it now.
      setup.synchronize_time('127.0.0.1')

    if options.test:
      logging.error("Could not contact any configuration server")
      sys.exit(3)

    setup.tickle_watchdog()

    logging.info("Going to sleep.")
    logging.info("")
    logging.info("")
    if not have_config:
      time.sleep(1)
    elif 'claim_key' in current_config:
      time.sleep(2)
    elif 'pairing_key' in current_config:
      time.sleep(5)
    else:
      time.sleep(60)

if __name__ == "__main__":
  main(sys.argv, sys.stdout, os.environ)

# vim: sw=2
