#!/bin/bash

targets=(
"ChromeSearch"
"ChromeDocumentations"	
"ChromeMailDict"
"ChromeDev"
"FirefoxCover"
)

echo "Hello, waiting the launches of these in order:"
echo ${targets[*]}
WIDs_file=$(test $1 && echo $1 || echo keybindings.sh)
echo The array of WIDs is at $WIDs_file

n=0
expecting=${#targets[@]}
counter=0
search_for='chrome\|firefox\|dev'


until [ $n -ge $expecting ] 
do
	n=$(wmctrl -l | grep -i $search_for | wc -l)
	echo "$n/$expecting, of the expected are(is) ready, iteration: $((++counter))"
	sleep 2
done

echo\
	"Reached ${expecting}"

wids=($(wmctrl -l | grep -i $search_for | grep -io '0x[^[:space:]]*'))

echo These are the wids ${wids[@]}

counter=0

for i in ${wids[@]}
do 
	iteration_match=${targets[((counter++))]}
	sed -i -r -e "s/^0x[^[:space:]]*[[:space:]]?(#$iteration_match#).*/$i \1 touched at $(date)/" $WIDs_file
done



















