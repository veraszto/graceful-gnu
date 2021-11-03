
#!/bin/bash

tmuxSep="\;"

vimLoaders=$(eval echo $MY_VIM_LOADERS_DIR)

for project in $@
do
	echo $project
	exec="tmux -f $MY_TMUX_CONF -S $MY_TMUX_SOCKET new-session -s $project $tmuxSep "

	for file in $(ls $vimLoaders)
	do
		isPertinent=$(echo $file | grep -i "^$project\.")
		if test -z "$isPertinent"
		then
			continue		
		fi
		buildCommand="vim -S $vimLoaders/$file"
		wname=$(echo ${file} | sed -e 's/^[^\.]*\.//' | sed -e 's/\.[^\.]\+$//' )
		sum="${hold}new-window -n ${wname} $buildCommand  $tmuxSep "
		#echo $wname
		hold="$sum"
	done

	hold="${sum:0:-3} $tmuxSep kill-window -t 0 $tmuxSep move-window -r $tmuxSep "

	run="$exec${hold:0:-3}"
	unset hold
	echo $run
	gnome-terminal --title "$project" -- /bin/bash --login -c "$run"

done


