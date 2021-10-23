
#All because to not zoom panel when its already zoomed 

isMain=$(echo -n $1 | grep -oi "^main$")

socket=$MY_TMUX_SOCKET_TOOLBOX
if [ -n "$isMain" ]
then
	socket=$MY_TMUX_SOCKET
fi

tmux="tmux -S $socket"

a=$($tmux list-panes -t $1:$2 | grep "(active)" | grep -o "^.")

$tmux select-window -t $1:$2

if test -z "$3"
then
	exit
fi

if [ $3 -ne $a ]
then
	$tmux select-pane -t $1:$2.$3
	$tmux resize-pane -Z -t $1:$2.$3
fi 
