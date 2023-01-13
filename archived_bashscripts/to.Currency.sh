#!/bin/bash


value=$1
radixCharacter=${2:-.}
length=${#value}
int=$((length % 3))
groups=()

if [ $length -le 3 ]
then
	echo $value
	exit
fi

for (( i = $length - 3, j = $(((length / 3) - 1)) ; i >= 0 ; i -= 3, j-- )) 
do
	groups[$j]=${value:$i:3}
done

built=""
for i in ${groups[@]}
do
	built="$built$radixCharacter${i}"
done

echo -n "${value:0:int}$built"
