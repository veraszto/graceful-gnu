
#!/bin/bash

tmuxSep="\;"

vimLoaders=$(eval echo $MY_VIM_LOADERS_DIR)

for project in $@
do
	cleanedProjectName=$(echo $project | sed -e 's/[^-A-Za-z_]//g')
	echo $cleanedProjectName
	exec="tmux -f $MY_TMUX_CONF -S $MY_TMUX_SOCKET new-session -s $cleanedProjectName $tmuxSep "

	eligible=$(find $vimLoaders -iregex ".*$cleanedProjectName\..*" | sort)

	for file in $eligible 
	do
		buildCommand="vim -S '$file'"
		wname=$(echo ${file} | sed -e 's/^[^\.]*\.//' | sed -e 's/\.[^\.]\+$//' )
		sum="${hold}new-window -n ${wname} $buildCommand  $tmuxSep "
		#echo "WName: $wname"
		#echo "BuildCommand: $buildCommand"
		hold="$sum"
	done


	if [ -z "$eligible" ]
	then
		sum="new-window -n Hello\! vim $tmuxSep "
	fi

	addBashContext="new-window $MY_BASH_CONTEXT $cleanedProjectName $tmuxSep "
	hold="${sum}${addBashContext}kill-window -t 0 $tmuxSep move-window -r $tmuxSep "

	run="$exec${hold:0:-3}"
	unset hold
	echo $run

	gnome-terminal --title "$project" -- /bin/bash --login -c "$run"

done


