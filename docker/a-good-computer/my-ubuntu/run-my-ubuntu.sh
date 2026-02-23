#!/bin/bash

xhost +local:docker

echo ${VOLUME_NAME:=my-volume}:${VOLUME_TARGET:=/root/volume}

docker run --rm -it \
--network host \
-e DISPLAY=$DISPLAY \
-v /tmp/.X11-unix:/tmp/.X11-unix \
--volume $VOLUME_NAME:$VOLUME_TARGET \
--name my-ubuntu \
veraszto/my-ubuntu
exit

#docker run --rm -it \
#--network host \
#--volume /run/user/1000/wayland-0:/run/root/wayland-0 \
#--env GTK_BACKEND=wayland \
#--env QT_QPA_PLATFORM=wayland \
#--env XDG_RUNTIME_DIR=/run/root \
#--env WAYLAND_DISPLAY=wayland-0 \
#--env DISPLAY=:0 \
#--volume $MY_VOLUME_SENSITIVE_DATA \
#--volume $MY_VOLUME_E_DATA_CONFIG \
#--name my-ubuntu \
#veraszto/my-ubuntu
#exit
