#!/bin/bash

docker container create --interactive --tty \
--network host \
--volume /run/user/1000/wayland-0:/run/root/wayland-0 \
--env GTK_BACKEND=wayland \
--env QT_QPA_PLATFORM=wayland \
--env XDG_RUNTIME_DIR=/run/root \
--env WAYLAND_DISPLAY=wayland-0 \
--env DISPLAY=:0 \
veraszto/my-basic-ubuntu:with-python
