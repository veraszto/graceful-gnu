
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
	sessionName=$(cat $path/config 2> /dev/null | grep "^name[[:space:]]" | sed -e 's/^name[[:space:]]\+//' | tail -n1 2> /dev/null)
	if [ $? -gt 0 -o -z "$sessionName" ]
	then
		builtSessionName="name "
		echo "Please add 'name <name>' to $path/config, type it in now I will build it for you!"
		read buildingSessionName
		while test -z "$buildingSessionName"; do
		{
			echo "Which name would you like to name tmux session? It cannot be empty as well as have no dots:"
			read buildingSessionName
		}; done
		builtSessionName="${builtSessionName}${buildingSessionName}"
		sessionName=$buildingSessionName
	fi
	gitProjectPath=$(cat $path/config  2> /dev/null| grep "^path[[:space:]]" | sed -e 's/^path[[:space:]]\+//' | tail -n1 2> /dev/null)
	if [ $? -gt 0 -o -z "$gitProjectPath" ]
	then
		builtProjectPath="path "
		echo "Please add 'path <path>' to $path/config, type it in now I will build it for you!"
		read buildingProjectPath
		while test -z "$buildingProjectPath"; do
		{
			echo "What is the path of the project, using it we will automate bashes with context"
			read buildingProjectPath
		}; done
		builtProjectPath="${builtProjectPath}${buildingProjectPath}"
		gitProjectPath=$buildingProjectPath
	fi
	if [ -n "$builtSessionName" ]; then
		echo -e "$builtSessionName" >> $path/config
	fi
	if [ -n "$builtProjectPath" ]; then
		echo -e "$builtProjectPath" >> $path/config
	fi
	sessionName=${sessionName}${RANDOM}
	echo "Matched prefix: $project"
	echo "Tmux session: $sessionName"
	echo "Tmux project path: ${gitProjectPath:=~/}"
	exec="tmux -f $MY_TMUX_CONF -S $MY_TMUX_SOCKET new-session -s \"$sessionName\" $tmuxSep "
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
	tmuxInitialDir="-c $gitProjectPath"
	addBashContext="new-window -n \"Holders\"  $tmuxInitialDir $tmuxSep split-window -h $tmuxInitialDir $tmuxSep "
	addBashContext="${addBashContext}new-window -n \"Input\" $tmuxInitialDir $tmuxSep "
	hold="${sum}${addBashContext}kill-window -t 0 $tmuxSep move-window -r $tmuxSep "
	hold="$hold set-buffer -b ${project}.loader.path \"$path\" $tmuxSep "
	hold="$hold set-buffer -b ${project}.project.path \"$gitProjectPath\" $tmuxSep "

	run="$exec${hold:0:-3}"
	unset hold	
	echo $run
	$MY_GNOME_TERMINAL_PROJECTS_LAUNCHER_INITIALIZATOR --title "$project" -- /bin/bash --login -c "$run"

done


