#!/bin/sh

convertsecs() 
{
    x=`expr $1 / 1000000`
    s=`expr $x % 60`
    x=`expr $x / 60`
    m=`expr $x % 60`
    printf "%02d:%02d\n" $m $s
}

POS=$(qdbus org.mpris.MediaPlayer2.clementine /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player Position)

NP=$(qdbus org.mpris.clementine /Player org.freedesktop.MediaPlayer.GetMetadata | grep -e "^title:" -e "^artist:" | sed -e '1s/$/ \-/' | cut -d " " -f2- | paste -d " " - -)

TOT=$(qdbus org.mpris.MediaPlayer2.clementine /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player Metadata | grep "^mpris:length" | awk '{print $2}')

if [[ ${NP} == "" ]]; then
    echo "Nothing playing"
else
    echo $NP \| $(convertsecs $POS)/$(convertsecs $TOT)
fi

