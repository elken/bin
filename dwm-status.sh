#!/bin/bash

normal="\x01"
red="\x05"
yellow="\x06"
green="\x07"
blue="\x0A"

getBattery() {
    perc=$(acpi -b | awk '/Battery/ {print $4}' | cut -d% -f1)
    time=$(acpi -b | awk '/Battery/ {print " (" substr($5,1,5)")"}')
    is_charging=$(acpi -a | awk '/Adapter/ {print $3}')

    if [ "${is_charging}" == "on-line" ]; then
        bat_icons=("" "" "")
    else
        bat_icons=("" "" "")
    fi

    if [ ${perc} -eq "100" ]; then
        echo -ne ""
    elif [ ${perc} -le "100" ]; then
        echo -ne "${green}${bat_icons[2]}${normal}${perc}"
    elif [ ${perc} -le "50" ]; then
        echo -ne "${yellow}${bat_icons[1]}${normal}${perc}"
    elif [ ${perc} -le "25" ]; then
        echo -ne "${red}${bat_icons[0]}${normal}${perc}${time}"
    fi
}

getCPU() {
    cpu=$(mpstat -P ALL 1 1 | awk '/Average:/ && $2 ~ /all/ {print $3}')
    if [ $(bc <<< "${cpu}<25") == 1 ]; then
        echo -ne "${green}"
    elif [ $(bc <<< "${cpu}<75") == 1 ]; then
        echo -ne "${yellow}"
    else
        echo -ne "${red}"
    fi
}

getMEM() {
     total=$(free -m | awk '/Mem:/ {print $2}')
     mem="$(bc <<< ${total}-$(free -m | awk '/Mem:/ {print $7}'))"
     if [ $(bc <<< "${mem}<$(echo ${total}* .25 | bc)") == 1 ]; then
        echo -ne "${green}"
     elif [ $(bc <<< "${mem}<$(echo ${total}* .5 | bc)") == 1 ]; then
        echo -ne "${yellow}"
     else
        echo -ne "${red}"
     fi
 }

getUpdates() {
    upd="$(cat ~/.total_updates)"
    if [ "${upd}" -le 0 ]; then
        echo -ne ""
    else
        echo -ne "${red} ${normal}${upd} "
    fi
}

getSound() {
    is_muted=$(amixer get Master | awk '/%/ {gsub(/[\[\]]/,""); print $6}' | tail -1)
    cur_device=$(pactl list sinks | awk '/Active Port:/ {print substr($3,15)}' | grep -v "^$")
    if [ ${cur_device} == "headphones" ]; then
        out_device="  "
    else
        out_device="  "
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
        if [ $(mpc | awk '/^\[/ {print $1}') == "[playing]" ]; then
            music_str+="${blue}"
        else
            music_str+="${blue}"
        fi
        if [ $(expr length "$(mpc current)") -le 50 ]; then
            music_str+=" $(mpc current) ($(mpc | head -2 | tail -1 | awk '{print $3}'))"
        else
            music_str+=" $(mpc current | ticker -l 50 -t 1000) ($(mpc | head -2 | tail -1 | awk '{print $3}'))" 
        fi
    else
        music_str+=""
    fi
    echo -ne "${music_str} "
}

getTime() {
    tme="$(date '+%A %D %H:%M')"
    echo -ne "${blue} ${normal}${tme}"
}

while true; do
    xsetroot -name "$(getSound)$(getMusic)$(getCPU) $(getMEM) $(getUpdates)$(getTime)"
done
