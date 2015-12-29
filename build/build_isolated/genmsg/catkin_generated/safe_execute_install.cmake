execute_process(COMMAND "/home/wil/projects/research/rosbeam/build/build_isolated/genmsg/catkin_generated/python_distutils_install.sh" RESULT_VARIABLE res)

if(NOT res EQUAL 0)
  message(FATAL_ERROR "execute_process(/home/wil/projects/research/rosbeam/build/build_isolated/genmsg/catkin_generated/python_distutils_install.sh) returned error code ")
endif()
