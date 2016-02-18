#include <ros/ros.h>
#include <nav_msgs/Odometry.h>
#include <geometry_msgs/Twist.h>
#include <tf2_msgs/TFMessage.h>
#include <std_msgs/String.h>
#include <string>

#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <pthread.h>
#include <string.h>
#include <errno.h>

#include <time.h>

#include "drive_command.h"

/* 
Inspect ros output on local machine for sanity-checking topics.
this is useful in the absence of being able to access ROS command-line tools
from the Beam.
*/

#define SHM_CMD 0
#define SHM_STAT 1
#define SLEEP_MILLISECONDS 250

void rostopic_list(int argc, char **argv)
{
    ros::init(argc, argv, "rostopic_list");
    printf("List of ROS Topic Available: \n");
    ros::master::V_TopicInfo ti;
    if(ros::master::getTopics(ti))
    {
        for(ros::master::V_TopicInfo::iterator it = ti.begin(); it != ti.end(); it++)
        {
            printf("%s\n", it->name.c_str());
        }
    }
}


/* cmd_vel singled out for subscription  (instead of odom, tf) because it's the one client-side input command. 
Feel free to add support for /odom and /tf. Ideally, we can just have the build install the generic ros-tools
onto the beam, but given the limited local ROS capabilities we need on the Beam itself, checking the most
important statuses might be enough for now.
*/
void check_cmd_vel(const geometry_msgs::Twist::ConstPtr& msg)
{
    ROS_INFO("received cmd_vel:");
    ROS_INFO("   ang_vel: %f", msg->angular.z);
    ROS_INFO("   lin_vel: %f", msg->linear.x);
}

void subscribe_cmd_vel(int argc, char **argv)
{
    ros::init(argc, argv, "inspector");
    ros::NodeHandle node;
    ROS_INFO("Subscribing to /beam/cmd_vel topic...");

    ros::Subscriber cmd_vel_checker = node.subscribe("/beam/cmd_vel", 10, check_cmd_vel);

    ros::spin();
}

/* 
 * Feel free to add more information to these printouts.
 */
void print_cmd(drive_command &cmd)
{
    printf("[CMD] {magic=%d, lin_vel=%d, ang_vel=%d, crc=%X}\n",
            cmd.magic, cmd.lin_vel, cmd.ang_vel, cmd.crc);

}

void print_stat(drive_status &stat)
{
    printf("[STAT] {magic=%d, encoder_1=%d, encoder_2=%d, crc=%X}\n",
            stat.magic, stat.encoder_1, stat.encoder_2, stat.crc);
}

/* poll the shared memory, and output whether it's currently a drive command (write)
   or a drive status command (read) */
void tail_shm(int shm_mode)
{
    struct drive_shm *shm;

    ROS_INFO("Polling shared memory on %s...", DRIVE_SHM_NAME);

    int fd = shm_open(DRIVE_SHM_NAME, O_RDWR, 0);

    if (fd < 0)
    {
        ROS_ERROR("shm_open: %s", strerror(errno));
        exit(EXIT_FAILURE);
    }
    
    shm = (struct drive_shm *)mmap(NULL, sizeof(*shm), PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

    if (close(fd) < 0)
        ROS_WARN("close: %s", strerror(errno));

    if (shm == MAP_FAILED) {
        ROS_ERROR("mmap: %s", strerror(errno));
        exit(EXIT_FAILURE);
    }
    
    struct timespec tv;
    int sleep_nanoseconds = SLEEP_MILLISECONDS * 1000000;
    tv.tv_sec = 0;
    tv.tv_nsec = sleep_nanoseconds;

    while (true)
    {
        
        if (shm == NULL)
        {
            continue;
        }
        
        //we're doing ad-hoc read-only from shm, so forget about locks.
        if (shm_mode == SHM_CMD)
        {
            print_cmd(shm->cmd);
        }
        else if (shm_mode == SHM_STAT)
        {
            print_stat(shm->stat);
        }

        nanosleep(&tv, &tv);

    }
}

void print_usage()
{
    printf("Usage: inspector [ cmd_vel | list_topics | shm $LOCATION ] \n");
}


/* Two inspection modes: 1) rostopic debugging, 2) Shared Memory debugging
     * for shared memory, it is necessary to provide the 
 */
int main(int argc, char **argv)
{
    if (argc < 2)
    {
        print_usage();
        exit(EXIT_SUCCESS);
    }

    std::string mode = argv[1];

    if (mode == "--usage" || mode == "--help")
    {
        printf("Usage: inspector [ cmd_vel | list_topics | shm [cmd | stat]] \n");
        //printf("    * cmd_vel - echo velocity data on /cmd_vel topic \n");
        //printf("    * list_topics - see all ROS topics on beam\n");
        //printf("    * shm [ cmd | stat ] - inspect shared memory, either for drive command (cmd) or status (stat)\n");
        exit(EXIT_SUCCESS);
    }
    else if (mode == "cmd_vel")
    {
        subscribe_cmd_vel(argc, argv);
    }
    else if (mode == "list_topics")
    {
        rostopic_list(argc, argv);
    }
    else if (mode == "shm")
    {
        if (argc != 3)
        {
            printf(" shm example: 'inspector shm cmd'\n");
            print_usage();
            exit(EXIT_SUCCESS);
        }

        std::string shm_mode = argv[2];

        printf("about to tail shm\n");
        if (shm_mode == "cmd")
        {
            tail_shm(SHM_CMD);
        }
        else if (shm_mode == "stat")
        {
            tail_shm(SHM_STAT);
        }
        else
        {
            printf(" error - shm arg must be either 'cmd' or 'stat'\n");
            print_usage();
            exit(EXIT_SUCCESS);
        }
    }
    else
    {
        print_usage();
    }

    return 0;
}
