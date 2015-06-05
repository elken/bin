#!/bin/sh
bg="#002b36"

conky -c ~/.dwm/.conky/network_popup| dzen2 -l 2 -w "250" -bg $bg -e '' -h 16 -ta c -sa 'l' -fn 'Meslo LG M for Powerline-10' -y '20' -x '870' -p -title-name 'popup_network' -e 'onstart=uncollapse;button1=exit;button3=exec:wicd-gtk;leaveslave=exit;leavetitle=exit' -p
