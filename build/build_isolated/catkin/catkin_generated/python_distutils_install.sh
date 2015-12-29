#!/bin/sh -x

if [ -n "$DESTDIR" ] ; then
    case $DESTDIR in
        /*) # ok
            ;;
        *)
            /bin/echo "DESTDIR argument must be absolute... "
            /bin/echo "otherwise python's distutils will bork things."
            exit 1
    esac
    DESTDIR_ARG="--root=$DESTDIR"
fi

cd "/home/wil/projects/research/rosbeam/build/src/catkin"

# Note that PYTHONPATH is pulled from the environment to support installing
# into one location when some dependencies were installed in another
# location, #123.
/usr/bin/env \
    PYTHONPATH="/home/wil/projects/research/rosbeam/build/install_isolated/lib/python3.5/site-packages:/home/wil/projects/research/rosbeam/build/build_isolated/catkin/lib/python3.5/site-packages:$PYTHONPATH" \
    CATKIN_BINARY_DIR="/home/wil/projects/research/rosbeam/build/build_isolated/catkin" \
    "/home/wil/projects/research/rosbeam/build/python/bin/python" \
    "/home/wil/projects/research/rosbeam/build/src/catkin/setup.py" \
    build --build-base "/home/wil/projects/research/rosbeam/build/build_isolated/catkin" \
    install \
    $DESTDIR_ARG \
     --prefix="/home/wil/projects/research/rosbeam/build/install_isolated" --install-scripts="/home/wil/projects/research/rosbeam/build/install_isolated/bin"
