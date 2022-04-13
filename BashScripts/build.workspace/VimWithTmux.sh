
#!/bin/bash

tmuxSep="\;"

vimLoaders=$(eval echo $MY_VIM_LOADERS_DIR)

bringPath()
{
	path=$(echo $1 | sed -e "s/\./\//g")	
	completePath="$vimLoaders/$path"
	echo $completePath
	if [ -d  "$completePath" ]
	then
		return 0
	fi
	return 1
}

for project in $@
do
	path=$(bringPath $project)
	foundProject=$?
	echo "Project path:"
	echo $path
	if [ $foundProject -gt 0 ]
	then
		echo "There is not a project in there"
		continue
	fi
	sessionName=$(cat $path/tmux.session.name 2>/dev/null)
	if [ $? -gt 0 ]
	then
		echo "Please add tmux.session.name to $path"
		continue
	fi
	echo "Tmux session:"
	echo $sessionName
	echo "Matched prefix:"
	echo $project
	echo
	exec="tmux -f $MY_TMUX_CONF -S $MY_TMUX_SOCKET new-session -s $sessionName $tmuxSep "

	eligible=$(find $path -iregex ".*.vim" | sort)

	for file in $eligible 
	do
		buildCommand="vim -S '$file'"
		#wname=$(echo ${file} | sed -e 's/^[^\.]*\.//' | sed -e 's/\.[^\.]\+$//' )
		wname=$(echo ${file} | sed -e "s/.*\///" | sed -e 's/\.[^\.]\+$//' )
		sum="${hold}new-window -n ${wname} $buildCommand  $tmuxSep "
		echo "WName: $wname"
		echo "BuildCommand: $buildCommand"
		echo
		hold="$sum"
	done


	if [ -z "$eligible" ]
	then
		sum="new-window -n Hello\! vim $tmuxSep "
	fi

	addBashContext="new-window $MY_BASH_CONTEXT $project $tmuxSep "
	hold="${sum}${addBashContext}kill-window -t 0 $tmuxSep move-window -r $tmuxSep "

	run="$exec${hold:0:-3}"
	unset hold
	echo $run
	echo

	gnome-terminal --title "$project" -- /bin/bash --login -c "$run"

done


