#!/bin/bash


if test $# -lt 3
then

	echo "Please put what, type(json or xml) and where"
	exit
fi

#a=${2:-"~/curls"}
savingTo="$3/curl.$1.response.$2"

echo
echo Curling $1 of type $2 and saving to $savingTo
echo

$3/curl.$1.sh > $savingTo


if test $2 = "json"
then
	npx json -4 -I -f $savingTo
else
	xmllint --format ${savingTo} --output $3/curl.$1.response.formated.$2
fi
