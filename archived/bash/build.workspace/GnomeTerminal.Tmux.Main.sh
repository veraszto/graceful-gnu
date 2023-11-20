#!/bin/bash

test -z "$1" && \
\
{
	gnome-terminal -- $HOME/GracefulGNU/BashScripts/build.workspace/MainWithTmux.sh
} || \
{
	podman container start fedora-toolbox-33 && \
	\
	gnome-terminal -- \
	$HOME/GracefulGNU/BashScripts/build.workspace/MainWithTmux.sh
}
