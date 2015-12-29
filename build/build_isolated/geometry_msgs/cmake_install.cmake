# Install script for directory: /home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/home/wil/projects/research/rosbeam/build/install_isolated")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "0")
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  
      if (NOT EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}")
        file(MAKE_DIRECTORY "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}")
      endif()
      if (NOT EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/.catkin")
        file(WRITE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/.catkin" "")
      endif()
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/wil/projects/research/rosbeam/build/install_isolated/_setup_util.py")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/home/wil/projects/research/rosbeam/build/install_isolated" TYPE PROGRAM FILES "/home/wil/projects/research/rosbeam/build/build_isolated/geometry_msgs/catkin_generated/installspace/_setup_util.py")
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/wil/projects/research/rosbeam/build/install_isolated/env.sh")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/home/wil/projects/research/rosbeam/build/install_isolated" TYPE PROGRAM FILES "/home/wil/projects/research/rosbeam/build/build_isolated/geometry_msgs/catkin_generated/installspace/env.sh")
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/wil/projects/research/rosbeam/build/install_isolated/setup.bash")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/home/wil/projects/research/rosbeam/build/install_isolated" TYPE FILE FILES "/home/wil/projects/research/rosbeam/build/build_isolated/geometry_msgs/catkin_generated/installspace/setup.bash")
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/wil/projects/research/rosbeam/build/install_isolated/setup.sh")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/home/wil/projects/research/rosbeam/build/install_isolated" TYPE FILE FILES "/home/wil/projects/research/rosbeam/build/build_isolated/geometry_msgs/catkin_generated/installspace/setup.sh")
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/wil/projects/research/rosbeam/build/install_isolated/setup.zsh")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/home/wil/projects/research/rosbeam/build/install_isolated" TYPE FILE FILES "/home/wil/projects/research/rosbeam/build/build_isolated/geometry_msgs/catkin_generated/installspace/setup.zsh")
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/wil/projects/research/rosbeam/build/install_isolated/.rosinstall")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/home/wil/projects/research/rosbeam/build/install_isolated" TYPE FILE FILES "/home/wil/projects/research/rosbeam/build/build_isolated/geometry_msgs/catkin_generated/installspace/.rosinstall")
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/etc/catkin/profile.d" TYPE FILE FILES "/home/wil/projects/research/rosbeam/build/install_isolated/share/catkin/cmake/env-hooks/05.catkin_make.bash")
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/etc/catkin/profile.d" TYPE FILE FILES "/home/wil/projects/research/rosbeam/build/install_isolated/share/catkin/cmake/env-hooks/05.catkin_make_isolated.bash")
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/geometry_msgs/msg" TYPE FILE FILES
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/Accel.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/AccelStamped.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/AccelWithCovariance.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/AccelWithCovarianceStamped.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/Point.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/Point32.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/PointStamped.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/Polygon.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/PolygonStamped.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/Pose2D.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/Pose.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/PoseArray.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/PoseStamped.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/PoseWithCovariance.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/PoseWithCovarianceStamped.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/Quaternion.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/QuaternionStamped.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/Transform.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/TransformStamped.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/Twist.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/TwistStamped.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/TwistWithCovariance.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/TwistWithCovarianceStamped.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/Vector3.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/Vector3Stamped.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/Wrench.msg"
    "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/msg/WrenchStamped.msg"
    )
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/geometry_msgs/cmake" TYPE FILE FILES "/home/wil/projects/research/rosbeam/build/build_isolated/geometry_msgs/catkin_generated/installspace/geometry_msgs-msg-paths.cmake")
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE DIRECTORY FILES "/home/wil/projects/research/rosbeam/build/devel_isolated/geometry_msgs/include/geometry_msgs")
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig" TYPE FILE FILES "/home/wil/projects/research/rosbeam/build/build_isolated/geometry_msgs/catkin_generated/installspace/geometry_msgs.pc")
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/geometry_msgs/cmake" TYPE FILE FILES "/home/wil/projects/research/rosbeam/build/build_isolated/geometry_msgs/catkin_generated/installspace/geometry_msgs-msg-extras.cmake")
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/geometry_msgs/cmake" TYPE FILE FILES
    "/home/wil/projects/research/rosbeam/build/build_isolated/geometry_msgs/catkin_generated/installspace/geometry_msgsConfig.cmake"
    "/home/wil/projects/research/rosbeam/build/build_isolated/geometry_msgs/catkin_generated/installspace/geometry_msgsConfig-version.cmake"
    )
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/geometry_msgs" TYPE FILE FILES "/home/wil/projects/research/rosbeam/build/src/common_msgs/geometry_msgs/package.xml")
endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/home/wil/projects/research/rosbeam/build/build_isolated/geometry_msgs/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
