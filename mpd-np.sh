#!/bin/sh

NP=`mpc current`
POS=`mpc | head -2 | tail -1 | awk '{print $3}'`

if [[ ${NP} == "" ]]; then
    echo "Nothing playing"
else
    echo ${NP} :: ${POS}
fi

