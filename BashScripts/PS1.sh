#clean_bash=${0#-}
#clean_bash=${clean_bash##*/}

unset PROMPT_COMMAND
cyan="\[\033[1;32m\]"
yellow="\[\033[1;46m\]"

green="\[\033[38;5;46m\]"
pink1="\[\033[38;5;197m\]"
pink3="\[\033[38;5;125m\]"
blue="\[\033[38;5;45m\]"
red="\[\033[38;5;196m\]"
orange="\[\033[38;5;209m\]"

finish="\[\033[0m\]"

lion="\xF0\x9F\xA6\x81"
teddybear="\xF0\x9F\xA7\xB8"
dollar="\xF0\x9F\x92\xB2"
home="\xF0\x9F\x8F\xA0"
horse="\xF0\x9F\x90\xB4"

function echoEscaped
{
	echo -en "$1"
}

function replacePWD
{
	pwd=$PWD
	nohome=${PWD/${HOME}/}
#	echo $pwd 1>&2
#	echo $nohome 1>&2
	if [ ${#nohome} -gt 0 ]
	then
		pwd=${nohome}
		echoEscaped ${home}
	elif [ $HOME = $PWD ]
	then
		echoEscaped ${home}
		return
	fi
	bars_counter=$(echo -n $pwd | tr "/" "\n" | wc -l)
#	echo $bars_counter 1>&2
	for (( i=0; i<${#pwd}; i++ ))
	do
		current=${pwd:$i:1}
		if [ $current = "/" ]
		then
			echoEscaped "$1${current}$finish"
		else
			echoEscaped "$2${current}$finish"
		fi

	done
}

function reloadPrompt
{
	if [ $USER = "root" ]
	then	
		PS1="${red}\u${finish}$(echoEscaped $horse)$(replacePWD $red $green)\\$ "
	else
		PS1="${pink1}\u${finish}$(echoEscaped $teddybear)$(replacePWD $pink1 $green)\\$ "
	fi
}

reloadPrompt
PROMPT_COMMAND="reloadPrompt"


