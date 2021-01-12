
#All because to not zoom panel when its already zoomed 

a=$(tmux -L $1 list-panes -t $1:$2 | grep "(active)" | grep -o "^.")

tmux -L $1 select-window -t $1:$2

if [ $3 -ne $a ]
then
	tmux -L $1 select-pane -t $1:$2.$3
	tmux -L $1 resize-pane -Z -t $1:$2
fi 
