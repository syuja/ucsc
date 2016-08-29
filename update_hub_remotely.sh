#!/bin/bash


E_OPTERROR=85

if [ $# -lt 1 ]    # Script invoked with no command-line args?
then
  echo "Usage: `basename $0` function genomesfile"
  exit $E_OPTERROR    # Exit and explain usage.
    # Usage: scriptname -options
    # Note: dash (-) necessary
fi

#set -e

genomesfile=$1
#option=$3

cols=$(head -n 1 $genomesfile)
i=0
