#!/bin/bash


selected=$(swaymsg -t get_workspaces | grep -i "\"\(name\|visible\)\"" | xargs | sed -e 's/\s//g' | \
	grep -io "1.visible.\(true\|false\)" | grep -io true)

isSelected=$(test -z $selected ; echo $?)

#echo "isSelected: $isSelected"

if test $isSelected -eq 1
then
	swaymsg workspace RightBottomCorner
	swaymsg workspace LeftBottom
	exit
fi

swaymsg workspace LeftTop
swaymsg workspace 1
