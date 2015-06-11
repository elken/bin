#!/bin/bash

normal="\x01"
red="\x05"
yellow="\x06"
green="\x07"
blue="\x0A"

getCPU() {
    cpu=$(mpstat -P ALL 1 1 | awk '/Average:/ && $2 ~ /all/ {print $3}')
    if [ $(bc <<< "${cpu}<25") == 1 ]; then
        echo -ne "${green}Ñ"
    elif [ $(bc <<< "${cpu}<75") == 1 ]; then
        echo -ne "${yellow}Ñ"
    else
        echo -ne "${red}Ñ"
    fi
}

 getMEM() {
     mem="$(free -m | awk '/-\/+/ {print $3}')"
     total=$(free -m | awk '/Mem:/ {print $2}')
     if [ $(bc <<< "${mem}<$(echo ${total}* .25 | bc)") == 1 ]; then
        echo -ne "${green}Î"
     elif [ $(bc <<< "${mem}<$(echo ${total}* .5 | bc)") == 1 ]; then
        echo -ne "${yellow}Î"
     else
        echo -ne "${red}Î"
     fi
 }

getUpdates() {
    upd="$(apt list --upgradable 2> /dev/null | wc -l)"
    if [ "${upd}" -le 1 ]; then
        echo -ne ""
    else
        echo -ne "${red}§${normal} ${upd} "
    fi
}

getSound() {
    is_muted=$(amixer get Master | awk '/Front Left:/ {print $6}' | tr -d '[]')
    cur_device=$(pactl list sinks | awk '/Active Port:/ {print substr($3,15)}' | grep -v "^$")
    if [ ${cur_device} == "headphones" ]; then
        out_device="à"
    else
        out_device="í"
    fi

    if [ ${is_muted} == "on" ]; then
        echo -ne "${green}${out_device}"
    else
        echo -ne "${red}${out_device}"
    fi

}

getMusic() {
    music_str="" 
    if [ "$(mpc current)" != "" ]; then
        if [ $(mpc | awk '/\[/ {print $1}') == "[playing]" ]; then
            music_str+="${blue}æ"
        else
            music_str+="${blue}ç"
        fi
        music_str+=" $(mpc current) ($(mpc | head -2 | tail -1 | awk '{print $3}'))"
    else
        music_str+=""
    fi
    echo -ne "${music_str}"
}

getTime() {
    tme="$(date '+ %H:%M')"
    echo -ne "${blue}É${normal}${tme}"
}

while true; do
    xsetroot -name "$(getSound)$(getMusic) $(getCPU) $(getMEM) $(getUpdates)$(getTime)"
done
