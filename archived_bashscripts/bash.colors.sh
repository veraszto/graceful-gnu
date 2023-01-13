#!/bin/bash


#for a in {30..48}
#do
#	for b in {0..4}
#	do
#		echo -e "\x1b[${b};${a}m$a) Hello how are you?"		
#	done
#done


for a in {0..255}
do
	echo -e "\e[48;5;${a}m $a) Hello how are you?\e[0m"
done
