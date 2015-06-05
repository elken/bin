#!/bin/sh
current=$(ls /run/openvpn | cut -d. -f1)
choice=$(echo "1: AMS_1\n2: AMS_2\n3: LON_3\n4: NYC_1\n5: Restart \"${current}\"" | dmenu -i -fn "Meslo LG M for Powerline-9" -nf "#586e75" -nb "#002b36" -sf "#268bd2" -sb "#002b36" | cut -f1)

case $choice in
    1) 
        if [ ${current} != "AMS_1" ]; then
            sudo systemctl stop openvpn@${current}.service
            sudo systemctl start openvpn@AMS_1.service
        fi
        ;;
    2)
        if [ ${current} != "AMS_2" ]; then
            sudo systemctl stop openvpn@${current}.service
            sudo systemctl start openvpn@AMS_2.service
        fi
        ;;
    3)
        if [ ${current} != "LON_3" ]; then
            sudo systemctl stop openvpn@${current}.service
            sudo systemctl start openvpn@LON_3.service
        fi
        ;;
    4)
        if [ ${current} != "NYC_1" ]; then
            sudo systemctl stop openvpn@${current}.service
            sudo systemctl start openvpn@NYC_1.service
        fi
        ;;
    5)
        sudo systemctl condrestart openvpn@${current}.service
        ;;
esac
