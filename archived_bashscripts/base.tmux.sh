#!/bin/bash
tmux -S $MY_TMUX_SOCKET has-session -t myTmux &> /dev/null
hasSession=$?
base='tmux -S $MY_TMUX_SOCKET'
if test $hasSession -gt 0; then
	andThen='-f $MY_TMUX_CONF new-session -s myTmuxSession -t myTmuxGroup \; '\
'splitw "man bash" \; select-layout even-horizontal \; '\
'new-window \; splitw \; splitw "journalctl --follow" \; splitw "TERM=xterm-256color htop" \; select-layout tiled'
	built="$base $andThen"
else
	andThen='new-session -t myTmuxGroup'
	built="$base $andThen"
fi
echo $built
gnome-terminal --full-screen -- /bin/bash -i -c "$built"
#gnome-terminal --full-screen
#'splitw "man bash" \; swap-pane -U \; select-layout even-horizontal \; '\
