#!/bin/bash


for a in {90..97}
do
	echo -e "\x1b[0;${a}m$a) Hello how are you?"
done
