#clean_bash=${0#-}
#clean_bash=${clean_bash##*/}

unset PROMPT_COMMAND

blue="45"
green="46"
orange="209"
pink1="197"
pink3="125"
red="196"

o225=225
o224=224
o223=223
o222=222
o221=221
o220=220

lighters=(177 176 175 174 173 172 178 179 180 181 182 45)


pack=($red $blue $pink3)
pack_oranges=($o225 $o224 $o223 $o222 $o221 $o220 $red)

finish="\[\033[0m\]"
template="\[\033[38;5;HEREm\]"

fillTemplate()
{
	echo ${template/HERE/$1}
}

generateFromPack()
{
	result=""
	for a in $@
	do
		result+=$(fillTemplate $a)
		result+=" "
	done
	echo $result
}

lion="\xF0\x9F\xA6\x81"
#teddybear="@"
#teddybear="\xF0\x9F\xA7\xB8"
teddybear="\360\237\247\270"
dollar="\xF0\x9F\x92\xB2"
dollar="\360\237\222\262"
#home="~"
#home="\xF0\x9F\x8F\xA0"
home="\360\237\217\240"
#horse="@"
horse="\xF0\x9F\x90\xB4"
horse="\360\237\220\264"
toolbox="\xf0\x9f\xa7\xb0"
toolbox="\360\237\247\260"

function echoEscaped
{
	echo -en "$1"
}

function echoNonEscaped
{
	echo -n "$1"
}

function replacePWD
{
	colors_each_dir=($@)
	colors_amount=$((${#colors_each_dir[@]} - 1))
	colors_last=$((colors_amount + 1))
	colors_index=0

	pwd=$PWD
	noHome="${PWD/${HOME}/}"
#	echo $pwd 1>&2
#	echo $nohome 1>&2
	if [ ${#PWD} -gt ${#noHome} ]
	then
		pwd=${noHome}
		echoNonEscaped ${home}
	elif [ $HOME = $PWD ]
	then
		echoNonEscaped ${home}
		return
	fi


#	bars_counter=$(echo -n $pwd | tr "/" "\n" | wc -l)
#	echo $bars_counter 1>&2

	switch=1
	for (( i=0; i<${#pwd}; i++ ))
	do
		current=${pwd:$i:1}
		if [ "$current" = "/" -a $i -eq 0 ]
		then
			echoNonEscaped "${!colors_last}${current}"
			switch=1
		elif [ "$current" = "/" ]
		then
			echoNonEscaped "${finish}${!colors_last}${current}"
			switch=1
		elif [ $switch -eq 1 ]
		then
			echoNonEscaped "$finish"
			echoNonEscaped "${colors_each_dir[$((colors_index++ % colors_amount))]}"
			echoNonEscaped "$current"
			switch=0
		else
			echoNonEscaped "$current"
		fi

	done
	echoNonEscaped "$finish"
}

function reloadPrompt
{
	colors=$(generateFromPack ${lighters[@]})
	pwd=$(replacePWD $colors)

	if [ "$USER" = "root" ]
	then	
		PS1="$(fillTemplate 88)\u${finish}$(echoNonEscaped $horse)${pwd}\\$ "
	else
		PS1="$(fillTemplate 147)\u${finish}$(echoNonEscaped $teddybear)${pwd}$(echoNonEscaped $dollar) "
	fi
}

reloadPrompt
PROMPT_COMMAND="reloadPrompt"


