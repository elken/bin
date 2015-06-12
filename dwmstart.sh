exec > ~/.logs/xsession 2>&1
export LANG="en_GB.UTF-8"
export LANGUAGE="en_GB.UTF-8"
setxkbmap -option terminate:ctrl_alt_bksp
setxkbmap gb
xset -dpms
xset s off
xsetroot -cursor_name left_ptr

[ ! -s ~/.config/mpd/pid ] && mpd &
emacs --daemon &
dunst &
steam &
thunar --daemon &
compton &
iceweasel &
icedove &

while true; do
        killall dwm-status.sh
        ~/bin/dwm-status.sh 2> ~/.logs/status &
        ~/.dwm/dwm 2> ~/.logs/dwm
done
