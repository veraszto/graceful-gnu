
#All because to not zoom panel when its already zoomed 

a=$(tmux list-panes -t $1:$2 | grep "(active)" | grep -o "^.")

tmux select-window -t $1:$2

if [ $3 -ne $a ]
then
	tmux select-pane -t $1:$2.$3
	tmux resize-pane -Z -t $1:$2
fi 
