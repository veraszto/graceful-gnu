
#!/bin/bash

tmuxSep=";"

exec="tmux -f $MY_TMUX_CONF -S $MY_TMUX_SOCKET new-session -s $1 $tmuxSep "

viewports=($2)
echo "${viewports[@]}"
for a in "${viewports[@]}"
do
	buildCommand="vim -S $MY_VIM_LOADERS_DIR/${a,,}.vim"
	sum="${hold}new-window -n ${a} $buildCommand  $tmuxSep "
	hold="$sum"
done

hold="${sum:0:-3} $tmuxSep kill-window -t 0 $tmuxSep move-window -r $tmuxSep "

done="$exec${hold:0:-3}"
$done

