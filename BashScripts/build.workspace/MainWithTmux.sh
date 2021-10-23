#!/bin/bash

mySessionTmux=${1:-Main}

tmux \
	-f $MY_TMUX_CONF \
	-S $MY_TMUX_SOCKET \
	new-session -s $mySessionTmux \; \
	rename-window "ReadCalmly" \; \
	split-window \; \
	new-window -n "Input" \; \
	split-window \; \
	split-window \; \
	select-layout -E \; \
	split-window \; \
	split-window \; \
	new-window -n "Docker" \; \
	split-window 


