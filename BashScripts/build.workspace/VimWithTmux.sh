
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
	echo "Project loader path: $path"
	if [ $foundProject -gt 0 ]
	then
		echo "There is not a project in there"
		continue
	fi
	sessionName=$(cat $path/config 2> /dev/null | grep "^name[[:space:]]" | sed -e 's/^name[[:space:]]\+//' | head -n1 2> /dev/null)
	if [ $? -gt 0 -o -z "$sessionName" ]
	then
		echo "Please add 'name <name>' to $path/config"
	fi
	gitProjectPath=$(cat $path/config  2> /dev/null| grep "^path[[:space:]]" | sed -e 's/^path[[:space:]]\+//' | head -n1 2> /dev/null)
	if [ $? -gt 0 -o -z "$gitProjectPath" ]
	then
		echo "Please add 'path <path>' to $path/config"
	fi
	sessionName=${sessionName}${RANDOM}
	echo "Matched prefix: $project"
	echo "Tmux session: $sessionName"
	echo "Tmux project path: ${gitProjectPath:=~/}"
	buildSessionName="new-session -s \"$sessionName\" $tmuxSep "
	exec="tmux -f $MY_TMUX_CONF -S $MY_TMUX_SOCKET $buildSessionName"
	eligible=$(find $path -iregex ".*\.vim$" | sort)
	for file in $eligible 
	do
		buildCommand="vim -S '$file'"
		#wname=$(echo ${file} | sed -e 's/^[^\.]*\.//' | sed -e 's/\.[^\.]\+$//' )
		wname=$(echo ${file} | sed -e "s/.*\///" | sed -e 's/\.[^\.]\+$//' )
		sum="${hold}new-window -n ${wname} $buildCommand  $tmuxSep "
		echo "WName: $wname"
		echo "BuildCommand: $buildCommand"
		hold="$sum"
	done


	if [ -z "$eligible" ]
	then
		sum="new-window -n Hello\! vim $tmuxSep "
	fi

	addBashContext="new-window $MY_BASH_CONTEXT $project $tmuxSep "
	#hold="${sum}${addBashContext}kill-window -t 0 $tmuxSep move-window -r $tmuxSep "
	hold="${sum}kill-window -t 0 $tmuxSep move-window -r $tmuxSep "
	hold="$hold set-buffer -b ${project}.loader.path \"$path\" $tmuxSep "
	hold="$hold set-buffer -b ${project}.project.path \"$gitProjectPath\" $tmuxSep "

	run="$exec${hold:0:-3}"
	unset hold	
	echo $run
	$MY_GNOME_TERMINAL_PROJECTS_LAUNCHER_INITIALIZATOR --title "$project" -- /bin/bash --login -c "$run"

done


