#!/bin/bash

echo Launching Chromes
for a in {1..4}
do
	:
	google-chrome &> /dev/null &
done

chromes=0
until test $chromes -ge 4
do
	chromes=$(wmctrl -l | grep -i chrome | wc -l)
	echo Waiting for Chromes, $chromes up to now
	sleep 2
done

echo And now one Firefox
firefox &> /dev/null &
