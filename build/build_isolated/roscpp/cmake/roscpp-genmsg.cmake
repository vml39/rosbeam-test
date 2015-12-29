# generated from genmsg/cmake/pkg-genmsg.cmake.em

message(STATUS "roscpp: 1 messages, 3 services")

set(MSG_I_FLAGS "-Iroscpp:/home/wil/projects/research/rosbeam/build/src/ros_comm/roscpp/msg")

# Find all generators
find_package(gencpp REQUIRED)

add_custom_target(roscpp_generate_messages ALL)

# verify that message/service dependencies have not changed since configure



get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/ros_comm/roscpp/srv/GetLoggers.srv" NAME_WE)
add_custom_target(_roscpp_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "roscpp" "/home/wil/projects/research/rosbeam/build/src/ros_comm/roscpp/srv/GetLoggers.srv" "roscpp/Logger"
)

get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/ros_comm/roscpp/srv/Empty.srv" NAME_WE)
add_custom_target(_roscpp_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "roscpp" "/home/wil/projects/research/rosbeam/build/src/ros_comm/roscpp/srv/Empty.srv" ""
)

get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/ros_comm/roscpp/msg/Logger.msg" NAME_WE)
add_custom_target(_roscpp_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "roscpp" "/home/wil/projects/research/rosbeam/build/src/ros_comm/roscpp/msg/Logger.msg" ""
)

get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/ros_comm/roscpp/srv/SetLoggerLevel.srv" NAME_WE)
add_custom_target(_roscpp_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "roscpp" "/home/wil/projects/research/rosbeam/build/src/ros_comm/roscpp/srv/SetLoggerLevel.srv" ""
)

#
#  langs = gencpp
#

### Section generating for lang: gencpp
### Generating Messages
_generate_msg_cpp(roscpp
  "/home/wil/projects/research/rosbeam/build/src/ros_comm/roscpp/msg/Logger.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/roscpp
)

### Generating Services
_generate_srv_cpp(roscpp
  "/home/wil/projects/research/rosbeam/build/src/ros_comm/roscpp/srv/GetLoggers.srv"
  "${MSG_I_FLAGS}"
  "/home/wil/projects/research/rosbeam/build/src/ros_comm/roscpp/msg/Logger.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/roscpp
)
_generate_srv_cpp(roscpp
  "/home/wil/projects/research/rosbeam/build/src/ros_comm/roscpp/srv/SetLoggerLevel.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/roscpp
)
_generate_srv_cpp(roscpp
  "/home/wil/projects/research/rosbeam/build/src/ros_comm/roscpp/srv/Empty.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/roscpp
)

### Generating Module File
_generate_module_cpp(roscpp
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/roscpp
  "${ALL_GEN_OUTPUT_FILES_cpp}"
)

add_custom_target(roscpp_generate_messages_cpp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_cpp}
)
add_dependencies(roscpp_generate_messages roscpp_generate_messages_cpp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/ros_comm/roscpp/srv/GetLoggers.srv" NAME_WE)
add_dependencies(roscpp_generate_messages_cpp _roscpp_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/ros_comm/roscpp/srv/Empty.srv" NAME_WE)
add_dependencies(roscpp_generate_messages_cpp _roscpp_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/ros_comm/roscpp/msg/Logger.msg" NAME_WE)
add_dependencies(roscpp_generate_messages_cpp _roscpp_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/ros_comm/roscpp/srv/SetLoggerLevel.srv" NAME_WE)
add_dependencies(roscpp_generate_messages_cpp _roscpp_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(roscpp_gencpp)
add_dependencies(roscpp_gencpp roscpp_generate_messages_cpp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS roscpp_generate_messages_cpp)



if(gencpp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/roscpp)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/roscpp
    DESTINATION ${gencpp_INSTALL_DIR}
  )
endif()
