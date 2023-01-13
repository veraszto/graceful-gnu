#!/bin/bash


gracefulgnu=$HOME/git/GracefulGNU/
graceful_git_screen_launcher="$gracefulgnu/screen/launcher.sh"
graceful_git_bashscript="$gracefulgnu/BashScripts/"

#swaymsg workspace 1
#swaymsg move workspace to output $output_left

screen -e "''" -c $gracefulgnu/screen/Right.Mine.conf -S Wrapper.MainRight
