exec > ~/.logs/xsession 2>&1
export LANG="en_GB.UTF-8"
export LANGUAGE="en_GB.UTF-8"
setxkbmap -option terminate:ctrl_alt_bksp
setxkbmap gb
xset -dpms
xset s off
xsetroot -cursor_name left_ptr
xset +fp /usr/share/fonts/misc
xset fp rehash
xrdb ~/.Xresources
xss-lock -- sflock &

[ ! -s ~/.config/mpd/pid ] && mpd &
nm-applet &
dropbox &
urxvtd -q -f -o &
pulseaudio --start &
nitrogen --restore &
emacs --daemon &
dunst &
thunar --daemon &
compton &
firefox &
thunderbird &
slack &

~/bin/dwm-status.sh 2> ~/.logs/status &
~/.dwm/dwm 2> ~/.logs/dwm
