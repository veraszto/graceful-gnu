#!/bin/bash

test -z "$1" && \
\
{
	gnome-terminal -- \
	$HOME/git/GracefulGNU/BashScripts/build.workspace/MainWithTmux.sh

} || \
{
	podman container start $1 && \
	podman container exec --interative --tty $1 \ 
	\
	gnome-terminal -- \
	/var/home/veraszto/git/GracefulGNU/BashScripts/build.workspace/MainWithTmux.Toolbox.sh
}
