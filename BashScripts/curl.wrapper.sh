#!/bin/bash


a=${2:-"~/curls"}
echo Curling $1 and saving to $a
$a/curl.$1.sh > $a/curl.$1.response.json
npx json -4 -I -f $a/curl.$1.response.json
