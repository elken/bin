exec > ~/.logs/xsession 2>&1
export LANG="en_GB.UTF-8"
export LANGUAGE="en_GB.UTF-8"
setxkbmap -option terminate:ctrl_alt_bksp
setxkbmap gb
xset -dpms
xset s off
xsetroot -cursor_name left_ptr

dunst &
nitrogen --restore &
steam &
emacs --daemon &
thunar --daemon &
urxvtd -q -f -o &
compton &
[ ! -s ~/.config/mpd/pid ] && mpd &
iceweasel &
icedove &

while true; do
        ~/bin/dwm-status.sh 2> ~/.logs/status &
        ~/.dwm/dwm 2> ~/.logs/dwm
done
