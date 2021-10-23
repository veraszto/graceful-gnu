#!/bin/bash

mySessionTmux=${1:-Toolbox}

tmux \
	-f $MY_TMUX_CONF \
	-S $MY_TMUX_SOCKET_TOOLBOX \
	new-session -s $mySessionTmux \; \
	rename-window "ReadCalmly" \; \
	split-window \; \
	new-window -n "Input" \; \
	split-window \; \
	split-window \; \
	select-layout -E \; \
	split-window \; \
	split-window \; \
	select-layout -E \; \
	split-window \; \
	split-window 


