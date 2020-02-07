

#! /bin/bash

browser="google-chrome"
terminal="gnome-terminal"
scripts="$HOME/git/GracefulGNU/BashScripts"

	case "$1" in
		0)
		swaymsg workspace 0 \; exec "$terminal -- bash -c -i -- \"$scripts/build.workspace/0.sh main\""
	;;
		1)
		swaymsg workspace LeftNonTerminal \; exec "$browser"
	;;
		2)
		swaymsg workspace RightNonTerminal \; exec "$terminal" \; exec "$browser"
	;;
		3)
		swaymsg workspace RightScreen \; exec "$terminal -- bash -c -i -- $scripts/build.workspace/Right.Mine.sh"
	;;
		4)
		swaymsg workspace 1 \; exec "$terminal --profile=Dan -- bash -c -i -- $scripts/build.workspace/1.sh"
	;;
	esac
