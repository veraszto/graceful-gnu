#! /bin/bash

if [ -z $1 ]; then
	tmux_session="main"
else
	tmux_session="$1"
fi


tmux \
	-f $HOME/git/GracefulGNU/tmux/tmux.conf \
	new-session -s $tmux_session \; \
	split-window \; select-layout even-vertical \; \
	split-window \; select-layout even-vertical \; \
	split-window \; select-layout even-vertical \; \
	select-pane -t:.1 \; resize-pane -Z
