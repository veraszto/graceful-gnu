#!/bin/bash

collection=(
0x02400006 #MainCODES			TMUX[0]
0x02400006 #Bash				TMUX[0:1]
0x02400006 #Vim					TMUX[0:2]
0x02400006 #Bash				TMUX[0:3]
0x02400067 #LeftLayout0 		SCREEN[0:0]
0x02400067 #LeftLayout1 		SCREEN[0:1]
0x02400067 #LeftLayout2 		SCREEN[0:2]
0x0240009b #Extras2# touched at Thu Jul 18 06:54:31 -03 2019
0x024000d3 #GIT# touched at Thu Jul 18 06:54:31 -03 2019
0x02400103 #Yards# touched at Thu Jul 18 06:54:31 -03 2019
0x02e00001 #ChromeSearch# touched at Mon Oct 28 06:48:33 -03 2019
0x02e0000a #ChromeDocumentations# touched at Mon Oct 28 06:48:33 -03 2019
0x03200008 ## touched at Fri Oct 11 06:46:10 -03 2019
0x02e0000c #ChromeDev# touched at Mon Oct 28 06:48:34 -03 2019
0x01c00010 #FirefoxCover# touched at Mon Oct 28 06:48:35 -03 2019
0x02465624
)

action=$1
chosen=${collection[$action]}
echo -e "$action -> $chosen\n"

test $action -eq 1 -o $action -eq 2 -o $action -eq 3 -o $action -eq 0 &&
{
	tmux="tmux select-window -t 0:$action"
	supplementary="screen -X -S Supplementary select $action"
#	$tmux
#	$supplementary
} || 
{
	test $action -eq 4 -o $action -eq 5 -o $action -eq 6 &&
	{
		#Gets the screen with lower PID
		screen="screen -X -S MainLeft select $(($action - 4))"
		$screen
	}
}

fill_with_action="wmctrl -i -a $chosen"
$fill_with_action



