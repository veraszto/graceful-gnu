#!/bin/bash

dir=${1:-$PWD}
if test -z $1; then
	echo "A <DIR> has not been given, we are using $dir then right?"
	read
fi
name=$(echo $dir | sed -e 's/\//./g' -e 's/^.//')
echo "Building workspace $name from $dir"
echo -e "\n\n[we are here]\n$dir/\n[search]\n-i \"\"\n[make tree]\n-I \"target|.git|node_modules|build|target\" --filelimit 50" >> $(eval echo $MY_VIM_WORKSPACES)/$name.workspaces
