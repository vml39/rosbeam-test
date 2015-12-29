# generated from genmsg/cmake/pkg-genmsg.cmake.em

message(STATUS "tf2_msgs: 2 messages, 1 services")

set(MSG_I_FLAGS "-Itf2_msgs:/home/wil/projects/research/rosbeam/build/src/geometry_experimental/tf2_msgs/msg;-Istd_msgs:/home/wil/projects/research/rosbeam/build/install_isolated/share/std_msgs/cmake/../msg;-Igeometry_msgs:/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg")

# Find all generators
find_package(gencpp REQUIRED)

add_custom_target(tf2_msgs_generate_messages ALL)

# verify that message/service dependencies have not changed since configure



get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/geometry_experimental/tf2_msgs/msg/TF2Error.msg" NAME_WE)
add_custom_target(_tf2_msgs_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "tf2_msgs" "/home/wil/projects/research/rosbeam/build/src/geometry_experimental/tf2_msgs/msg/TF2Error.msg" ""
)

get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/geometry_experimental/tf2_msgs/srv/FrameGraph.srv" NAME_WE)
add_custom_target(_tf2_msgs_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "tf2_msgs" "/home/wil/projects/research/rosbeam/build/src/geometry_experimental/tf2_msgs/srv/FrameGraph.srv" ""
)

get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/geometry_experimental/tf2_msgs/msg/TFMessage.msg" NAME_WE)
add_custom_target(_tf2_msgs_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "tf2_msgs" "/home/wil/projects/research/rosbeam/build/src/geometry_experimental/tf2_msgs/msg/TFMessage.msg" "geometry_msgs/TransformStamped:geometry_msgs/Transform:geometry_msgs/Quaternion:geometry_msgs/Vector3:std_msgs/Header"
)

#
#  langs = gencpp
#

### Section generating for lang: gencpp
### Generating Messages
_generate_msg_cpp(tf2_msgs
  "/home/wil/projects/research/rosbeam/build/src/geometry_experimental/tf2_msgs/msg/TF2Error.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/tf2_msgs
)
_generate_msg_cpp(tf2_msgs
  "/home/wil/projects/research/rosbeam/build/src/geometry_experimental/tf2_msgs/msg/TFMessage.msg"
  "${MSG_I_FLAGS}"
  "/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/TransformStamped.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Transform.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Quaternion.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Vector3.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/tf2_msgs
)

### Generating Services
_generate_srv_cpp(tf2_msgs
  "/home/wil/projects/research/rosbeam/build/src/geometry_experimental/tf2_msgs/srv/FrameGraph.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/tf2_msgs
)

### Generating Module File
_generate_module_cpp(tf2_msgs
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/tf2_msgs
  "${ALL_GEN_OUTPUT_FILES_cpp}"
)

add_custom_target(tf2_msgs_generate_messages_cpp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_cpp}
)
add_dependencies(tf2_msgs_generate_messages tf2_msgs_generate_messages_cpp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/geometry_experimental/tf2_msgs/msg/TF2Error.msg" NAME_WE)
add_dependencies(tf2_msgs_generate_messages_cpp _tf2_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/geometry_experimental/tf2_msgs/srv/FrameGraph.srv" NAME_WE)
add_dependencies(tf2_msgs_generate_messages_cpp _tf2_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/geometry_experimental/tf2_msgs/msg/TFMessage.msg" NAME_WE)
add_dependencies(tf2_msgs_generate_messages_cpp _tf2_msgs_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(tf2_msgs_gencpp)
add_dependencies(tf2_msgs_gencpp tf2_msgs_generate_messages_cpp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS tf2_msgs_generate_messages_cpp)



if(gencpp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/tf2_msgs)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/tf2_msgs
    DESTINATION ${gencpp_INSTALL_DIR}
  )
endif()
add_dependencies(tf2_msgs_generate_messages_cpp std_msgs_generate_messages_cpp)
add_dependencies(tf2_msgs_generate_messages_cpp geometry_msgs_generate_messages_cpp)
