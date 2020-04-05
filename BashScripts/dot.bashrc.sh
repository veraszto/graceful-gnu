#!/bin/bash
#
## .bashrc 
# Source global definitions

#history is set later
test $BASHRCSOURCED || unset HISTFILE

if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi


