#!/bin/bash

#xhost

docker run --rm -it \
--network host \
--volume /run/user/1000/wayland-0:/run/root/wayland-0 \
--env GTK_BACKEND=wayland \
--env QT_QPA_PLATFORM=wayland \
--env XDG_RUNTIME_DIR=/run/root \
--env WAYLAND_DISPLAY=wayland-0 \
--env DISPLAY=:0 \
--name my-electrum \
veraszto/my-basic-ubuntu:with-python
exit

docker run --rm -it \
--network host \
--volume /tmp/.X11-unix/:/tmp/.X11-unix/ \
--env DISPLAY=:0 \
--name my-electrum \
veraszto/my-basic-ubuntu:with-python
exit

docker run --rm -it \
--network host \
--volume /tmp/.X11-unix/:/tmp/.X11-unix/ \
--volume /run/user/1000/wayland-0:/run/root/wayland-0 \
--env GTK_BACKEND=wayland \
--env QT_QPA_PLATFORM=wayland \
--env XDG_RUNTIME_DIR=/run/root \
--env WAYLAND_DISPLAY=wayland-0 \
--env DISPLAY=:0 \
veraszto/my-basic-ubuntu
