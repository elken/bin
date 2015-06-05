exec > ~/.logs/xsession 2>&1
export LANG="en_GB.UTF-8"
export LANGUAGE="en_GB.UTF-8"
setxkbmap -option terminate:ctrl_alt_bksp
setxkbmap gb
xset -dpms
xset s off
xsetroot -cursor_name left_ptr

dunst 2>&1 ~/.logs/dunst &
nitrogen --restore &
steam 2>&1 ~/.logs/steam &
emacs --daemon 2>&1 ~/.logs/emacs&
thunar --daemon &
urxvtd -q -f -o 2>&1 ~/.logs/urxvt &
compton 2>&1 ~/.logs/compton &
if [ ! -e /tmp/dwm.fifo ]; then mkfifo /tmp/dwm.fifo; fi
[ ! -s ~/.config/mpd/pid ] && mpd &
iceweasel 2>&1 ~/.logs/iceweasel &
icedove 2>&1 ~/.logs/icedove &

while true; do
        killall conky dzen2 ; ~/bin/conky-dzen 2>&1 ~/.logs/conky-dzen &
	~/.dwm/dwm 2>&1 ~/.logs/dwm
done
