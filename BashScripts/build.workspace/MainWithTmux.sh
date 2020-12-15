#! /bin/bash


tmux \
	-f $HOME/git/GracefulGNU/tmux/tmux.conf \
	new-session -s ${1:-Main} \; \
	rename-window "ReadCalmly" \; \
	split-window \; \
	new-window -n "Vim" \; \
	split-window \; \
	new-window -n "Input" \; \
	split-window \; \
	split-window \; \
	split-window \; \
	new-window -n "Docker" \; \
	split-window 


