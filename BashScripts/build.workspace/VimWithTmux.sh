
#!/bin/bash

tmuxSep=";"

exec="tmux -f $HOME/git/GracefulGNU/tmux/toolbox.conf -L Vim new-session -s Vim $tmuxSep "

viewports=($MY_TMUX_VIMS_LOADERS)
for a in "${viewports[@]}"
do
	buildCommand="vim -S $MY_VIM_LOADERS_DIR/${a,,}.vim"
	sum="${hold}new-window -n ${a} $buildCommand  $tmuxSep "
	hold="$sum"
done

hold="${sum:0:-3} $tmuxSep kill-window -t 0 $tmuxSep move-window -r $tmuxSep "

done="$exec${hold:0:-3}"
$done

