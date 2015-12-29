# generated from genmsg/cmake/pkg-genmsg.cmake.em

message(STATUS "rosgraph_msgs: 3 messages, 0 services")

set(MSG_I_FLAGS "-Irosgraph_msgs:/home/wil/projects/research/rosbeam/build/src/ros_comm_msgs/rosgraph_msgs/msg;-Istd_msgs:/home/wil/projects/research/rosbeam/build/install_isolated/share/std_msgs/cmake/../msg")

# Find all generators
find_package(gencpp REQUIRED)

add_custom_target(rosgraph_msgs_generate_messages ALL)

# verify that message/service dependencies have not changed since configure



get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/ros_comm_msgs/rosgraph_msgs/msg/TopicStatistics.msg" NAME_WE)
add_custom_target(_rosgraph_msgs_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "rosgraph_msgs" "/home/wil/projects/research/rosbeam/build/src/ros_comm_msgs/rosgraph_msgs/msg/TopicStatistics.msg" ""
)

get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/ros_comm_msgs/rosgraph_msgs/msg/Log.msg" NAME_WE)
add_custom_target(_rosgraph_msgs_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "rosgraph_msgs" "/home/wil/projects/research/rosbeam/build/src/ros_comm_msgs/rosgraph_msgs/msg/Log.msg" "std_msgs/Header"
)

get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/ros_comm_msgs/rosgraph_msgs/msg/Clock.msg" NAME_WE)
add_custom_target(_rosgraph_msgs_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "rosgraph_msgs" "/home/wil/projects/research/rosbeam/build/src/ros_comm_msgs/rosgraph_msgs/msg/Clock.msg" ""
)

#
#  langs = gencpp
#

### Section generating for lang: gencpp
### Generating Messages
_generate_msg_cpp(rosgraph_msgs
  "/home/wil/projects/research/rosbeam/build/src/ros_comm_msgs/rosgraph_msgs/msg/TopicStatistics.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/rosgraph_msgs
)
_generate_msg_cpp(rosgraph_msgs
  "/home/wil/projects/research/rosbeam/build/src/ros_comm_msgs/rosgraph_msgs/msg/Log.msg"
  "${MSG_I_FLAGS}"
  "/home/wil/projects/research/rosbeam/build/install_isolated/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/rosgraph_msgs
)
_generate_msg_cpp(rosgraph_msgs
  "/home/wil/projects/research/rosbeam/build/src/ros_comm_msgs/rosgraph_msgs/msg/Clock.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/rosgraph_msgs
)

### Generating Services

### Generating Module File
_generate_module_cpp(rosgraph_msgs
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/rosgraph_msgs
  "${ALL_GEN_OUTPUT_FILES_cpp}"
)

add_custom_target(rosgraph_msgs_generate_messages_cpp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_cpp}
)
add_dependencies(rosgraph_msgs_generate_messages rosgraph_msgs_generate_messages_cpp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/ros_comm_msgs/rosgraph_msgs/msg/TopicStatistics.msg" NAME_WE)
add_dependencies(rosgraph_msgs_generate_messages_cpp _rosgraph_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/ros_comm_msgs/rosgraph_msgs/msg/Log.msg" NAME_WE)
add_dependencies(rosgraph_msgs_generate_messages_cpp _rosgraph_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/ros_comm_msgs/rosgraph_msgs/msg/Clock.msg" NAME_WE)
add_dependencies(rosgraph_msgs_generate_messages_cpp _rosgraph_msgs_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(rosgraph_msgs_gencpp)
add_dependencies(rosgraph_msgs_gencpp rosgraph_msgs_generate_messages_cpp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS rosgraph_msgs_generate_messages_cpp)



if(gencpp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/rosgraph_msgs)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/rosgraph_msgs
    DESTINATION ${gencpp_INSTALL_DIR}
  )
endif()
add_dependencies(rosgraph_msgs_generate_messages_cpp std_msgs_generate_messages_cpp)
