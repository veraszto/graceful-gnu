#!/bin/bash
#
## .bashrc 
# Source global definitions

#history is set later
#test $BASHRCSOURCED || unset HISTFILE

unset VTE_VERSION

if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi


export LD_LIBRARY_PATH=/usr/local/lib64/
