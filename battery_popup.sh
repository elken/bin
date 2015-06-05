#!/bin/sh
bg="#002b36"

conky -c ~/.dwm/.conky/battery_popup| dzen2 -l 1 -w "120" -bg $bg -e '' -h 16 -ta c -sa 'l' -fn 'Meslo LG M for Powerline-10' -y '20' -x '1030' -title-name 'popup_battery' -e 'onstart=uncollapse;button1=exit;leaveslave=exit;leavetitle=exit' -p
