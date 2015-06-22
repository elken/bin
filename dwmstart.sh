exec > ~/.logs/xsession 2>&1
export LANG="en_GB.UTF-8"
export LANGUAGE="en_GB.UTF-8"
setxkbmap -option terminate:ctrl_alt_bksp
setxkbmap gb
xset -dpms
xset s off
xsetroot -cursor_name left_ptr
xset +fp /usr/share/fonts/local
xset +fp /usr/share/fonts/misc
xset fp rehash

[ ! -s ~/.config/mpd/pid ] && mpd &
pulse --start &
nitrogen --restore &
wicd-gtk -t &
emacs --daemon &
dunst &
thunar --daemon &
compton &
firefox &
thunderbird &

~/bin/dwm-status.sh 2> ~/.logs/status &
~/.dwm/dwm 2> ~/.logs/dwm
