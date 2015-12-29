# generated from genmsg/cmake/pkg-genmsg.cmake.em

message(STATUS "nav_msgs: 5 messages, 3 services")

set(MSG_I_FLAGS "-Inav_msgs:/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg;-Igeometry_msgs:/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg;-Istd_msgs:/home/wil/projects/research/rosbeam/build/install_isolated/share/std_msgs/cmake/../msg")

# Find all generators
find_package(gencpp REQUIRED)

add_custom_target(nav_msgs_generate_messages ALL)

# verify that message/service dependencies have not changed since configure



get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/srv/GetPlan.srv" NAME_WE)
add_custom_target(_nav_msgs_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "nav_msgs" "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/srv/GetPlan.srv" "geometry_msgs/Quaternion:nav_msgs/Path:geometry_msgs/Pose:std_msgs/Header:geometry_msgs/PoseStamped:geometry_msgs/Point"
)

get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/srv/SetMap.srv" NAME_WE)
add_custom_target(_nav_msgs_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "nav_msgs" "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/srv/SetMap.srv" "geometry_msgs/Quaternion:nav_msgs/OccupancyGrid:geometry_msgs/PoseWithCovariance:geometry_msgs/Pose:std_msgs/Header:geometry_msgs/PoseWithCovarianceStamped:geometry_msgs/Point:nav_msgs/MapMetaData"
)

get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/Path.msg" NAME_WE)
add_custom_target(_nav_msgs_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "nav_msgs" "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/Path.msg" "geometry_msgs/PoseStamped:geometry_msgs/Point:geometry_msgs/Pose:std_msgs/Header:geometry_msgs/Quaternion"
)

get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/MapMetaData.msg" NAME_WE)
add_custom_target(_nav_msgs_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "nav_msgs" "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/MapMetaData.msg" "geometry_msgs/Point:geometry_msgs/Pose:geometry_msgs/Quaternion"
)

get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/OccupancyGrid.msg" NAME_WE)
add_custom_target(_nav_msgs_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "nav_msgs" "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/OccupancyGrid.msg" "geometry_msgs/Point:nav_msgs/MapMetaData:geometry_msgs/Pose:std_msgs/Header:geometry_msgs/Quaternion"
)

get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/Odometry.msg" NAME_WE)
add_custom_target(_nav_msgs_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "nav_msgs" "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/Odometry.msg" "geometry_msgs/Quaternion:geometry_msgs/TwistWithCovariance:geometry_msgs/Twist:geometry_msgs/Vector3:geometry_msgs/PoseWithCovariance:geometry_msgs/Pose:std_msgs/Header:geometry_msgs/Point"
)

get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/GridCells.msg" NAME_WE)
add_custom_target(_nav_msgs_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "nav_msgs" "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/GridCells.msg" "geometry_msgs/Point:std_msgs/Header"
)

get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/srv/GetMap.srv" NAME_WE)
add_custom_target(_nav_msgs_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "nav_msgs" "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/srv/GetMap.srv" "geometry_msgs/Quaternion:nav_msgs/OccupancyGrid:geometry_msgs/Pose:std_msgs/Header:geometry_msgs/Point:nav_msgs/MapMetaData"
)

#
#  langs = gencpp
#

### Section generating for lang: gencpp
### Generating Messages
_generate_msg_cpp(nav_msgs
  "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/Path.msg"
  "${MSG_I_FLAGS}"
  "/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/PoseStamped.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Point.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Pose.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/std_msgs/cmake/../msg/Header.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Quaternion.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/nav_msgs
)
_generate_msg_cpp(nav_msgs
  "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/MapMetaData.msg"
  "${MSG_I_FLAGS}"
  "/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Point.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Pose.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Quaternion.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/nav_msgs
)
_generate_msg_cpp(nav_msgs
  "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/OccupancyGrid.msg"
  "${MSG_I_FLAGS}"
  "/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Point.msg;/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/MapMetaData.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Pose.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/std_msgs/cmake/../msg/Header.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Quaternion.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/nav_msgs
)
_generate_msg_cpp(nav_msgs
  "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/Odometry.msg"
  "${MSG_I_FLAGS}"
  "/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Quaternion.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/TwistWithCovariance.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Twist.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Vector3.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/PoseWithCovariance.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Pose.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/std_msgs/cmake/../msg/Header.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Point.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/nav_msgs
)
_generate_msg_cpp(nav_msgs
  "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/GridCells.msg"
  "${MSG_I_FLAGS}"
  "/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Point.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/nav_msgs
)

### Generating Services
_generate_srv_cpp(nav_msgs
  "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/srv/SetMap.srv"
  "${MSG_I_FLAGS}"
  "/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Quaternion.msg;/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/OccupancyGrid.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/PoseWithCovariance.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Pose.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/std_msgs/cmake/../msg/Header.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/PoseWithCovarianceStamped.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Point.msg;/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/MapMetaData.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/nav_msgs
)
_generate_srv_cpp(nav_msgs
  "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/srv/GetPlan.srv"
  "${MSG_I_FLAGS}"
  "/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Quaternion.msg;/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/Path.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Pose.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/std_msgs/cmake/../msg/Header.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/PoseStamped.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Point.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/nav_msgs
)
_generate_srv_cpp(nav_msgs
  "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/srv/GetMap.srv"
  "${MSG_I_FLAGS}"
  "/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Quaternion.msg;/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/OccupancyGrid.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Pose.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/std_msgs/cmake/../msg/Header.msg;/home/wil/projects/research/rosbeam/build/install_isolated/share/geometry_msgs/cmake/../msg/Point.msg;/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/MapMetaData.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/nav_msgs
)

### Generating Module File
_generate_module_cpp(nav_msgs
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/nav_msgs
  "${ALL_GEN_OUTPUT_FILES_cpp}"
)

add_custom_target(nav_msgs_generate_messages_cpp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_cpp}
)
add_dependencies(nav_msgs_generate_messages nav_msgs_generate_messages_cpp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/srv/GetPlan.srv" NAME_WE)
add_dependencies(nav_msgs_generate_messages_cpp _nav_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/srv/SetMap.srv" NAME_WE)
add_dependencies(nav_msgs_generate_messages_cpp _nav_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/Path.msg" NAME_WE)
add_dependencies(nav_msgs_generate_messages_cpp _nav_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/MapMetaData.msg" NAME_WE)
add_dependencies(nav_msgs_generate_messages_cpp _nav_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/OccupancyGrid.msg" NAME_WE)
add_dependencies(nav_msgs_generate_messages_cpp _nav_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/Odometry.msg" NAME_WE)
add_dependencies(nav_msgs_generate_messages_cpp _nav_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/msg/GridCells.msg" NAME_WE)
add_dependencies(nav_msgs_generate_messages_cpp _nav_msgs_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/wil/projects/research/rosbeam/build/src/common_msgs/nav_msgs/srv/GetMap.srv" NAME_WE)
add_dependencies(nav_msgs_generate_messages_cpp _nav_msgs_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(nav_msgs_gencpp)
add_dependencies(nav_msgs_gencpp nav_msgs_generate_messages_cpp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS nav_msgs_generate_messages_cpp)



if(gencpp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/nav_msgs)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/nav_msgs
    DESTINATION ${gencpp_INSTALL_DIR}
  )
endif()
add_dependencies(nav_msgs_generate_messages_cpp geometry_msgs_generate_messages_cpp)
add_dependencies(nav_msgs_generate_messages_cpp std_msgs_generate_messages_cpp)
