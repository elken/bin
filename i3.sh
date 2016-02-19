exec > .logs/xsession 2>&1
export LANG="en_GB.UTF-8"
export LANGUAGE="en_GB.UTF-8"
xrdb -merge ~/.Xresources
setxkbmap -option terminate:ctrl_alt_bksp
xset -dpms; xset s off
xsetroot -cursor_name left_ptr
xset +fp /usr/share/fonts/local
xset fp rehash

setxkbmap gb
nitrogen --restore &
[ ! -s ~/.config/mpd/pid  ] && mpd &
rm /tmp/$(ls /tmp | grep bspwm)

exec i3 -V 2> ~/.logs/i3 
