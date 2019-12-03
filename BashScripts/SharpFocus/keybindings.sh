#!/bin/bash

collection=(
0x02400006 #MainCODES			TMUX[0]
0x024083db #Bash				TMUX[0:1]
0x024083db #Vim					TMUX[0:2]
0x024083db #Bash				TMUX[0:3]
0x024083db #LeftLayout0 		SCREEN[0:0]
0x024083db #LeftLayout1 		SCREEN[0:1]
0x024083db #LeftLayout2 		SCREEN[0:2]
0x024083db #Extras2# touched at Thu Jul 18 06:54:31 -03 2019
0x024083db #GIT# touched at Thu Jul 18 06:54:31 -03 2019
0x024083db #Yards# touched at Thu Jul 18 06:54:31 -03 2019
0x02e00001 #ChromeSearch# touched at Thu Oct 31 06:52:15 -03 2019
0x02e00006 #ChromeDocumentations# touched at Thu Oct 31 06:52:16 -03 2019
0x03200008 ## touched at Fri Oct 11 06:46:10 -03 2019
0x02e00008 #ChromeDev# touched at Thu Oct 31 06:52:16 -03 2019
0x02200010 #FirefoxCover# touched at Thu Oct 31 06:52:16 -03 2019
0x024083db
)

action=$1
chosen=${collection[$action]}
echo -e "$action -> $chosen\n"

test $action -eq 0 &&
{
	tmux="tmux select-window -t 0:$action"
	supplementary="screen -X -S Supplementary select $action"
#	$tmux
#	$supplementary
} || 
{
	test\
		$action -gt 0 -a\
		$action -le 9 &&\
	{
		#Gets the screen with lower PID
		screen="screen -X -S MainLeft select $action"
		$screen
	}
}

fill_with_action="wmctrl -i -a $chosen"
$fill_with_action



