#!/bin/bash

mySessionTmux=${1:-Toolbox}

tmux \
	-f $HOME/git/GracefulGNU/tmux/toolbox.conf \
	-L $mySessionTmux \
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


