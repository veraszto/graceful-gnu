#!/bin/bash

mySessionTmux=${1:-Toolbox}

tmux \
	-f $MY_TMUX_CONF \
	-S $MY_TMUX_SOCKET_TOOLBOX \
	new-session -s $mySessionTmux \; \
	rename-window "ReadCalmly" \; \
	split-window \; \
	select-pane -t 0 \; \
	resize-pane -Z \; \
	new-window -n "Input" \; \
	split-window \; \
	split-window \; \
	select-pane -t 0 \; \
	resize-pane -Z


