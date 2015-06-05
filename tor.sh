#!/bin/sh

colorR="\e[38;5;1m"
colorG="\e[38;5;2m"
colorW="\e[38;5;7m"
reset="\e[0m"

tor_status=$(systemctl status tor | grep Active: | awk '{print $2}')
iptables_status=$(systemctl status iptables | grep Active: | awk '{print $2}')
vpn_status=$(ip a | grep -c tun0)

get_status()
{
    echo -e "${colorW}Status:\n"
    if [ "${tor_status}" == "active" ] ; then
        echo -e "${colorW}Tor:\t\t${colorG}${tor_status}"
    fi
    if [ "${iptables_status}" == "active" ] ; then
        echo -e "${colorW}IPTables:\t${colorG}${iptables_status}${reset}"
    fi
    if [ "${tor_status}" == "inactive" ]; then
        echo -e "${colorW}Tor:\t\t${colorR}${tor_status}"
    fi
    if [ "${iptables_status}" == "inactive" ]; then
        echo -e "${colorW}IPTables:\t${colorR}${iptables_status}${reset}"
    fi
    if [ "${vpn_status}" -ne 0 ]; then
        echo -e "${colorW}VPN:\t\t${colorG}active${reset}${colorW} ($(nmcli -t -f NAME,TYPE c show --active | grep -v tun0 | grep vpn | cut -d : -f1))"

    fi
    if [ "${vpn_status}" -eq 0 ]; then
        echo -e "${colorW}VPN:\t\t${colorR}inactive${reset}"
    fi
}

set_status()
{
    if [ "$1" == "on" ]; then
        if [ "${tor_status}" == "inactive" ]; then
            echo -e "${colorG}Turning Tor on ...${reset}"
            systemctl start tor
        fi
        if [ "${iptables_status}" == "inactive" ]; then
            echo -e "${colorG}Turning IPTables on ...${reset}"
            systemctl start iptables
        fi
    elif [ "$1" == "off" ]; then
        if [ "${tor_status}" == "active" ]; then
            echo -e "${colorR}Turning Tor off ...${reset}"
            systemctl stop tor
        fi
        if [ "${iptables_status}" == "active" ]; then
            echo -e "${colorR}Turning IPTables off ...${reset}"
            systemctl stop iptables
        fi
    else
        echo -e "${colorR}Wrong args passed."
        exit 1
    fi
}

main()
{
    if [ "$EUID" -ne 0 ]; then
        echo -e "${colorR}Please run as root"
        exit 1
    fi
    if [ "$#" -eq 0 ]; then
        get_status
    fi
    local OPTIND
    while getopts gs: opt; do
        case $opt in
            g)
                get_status
                ;;
            s)
                set_status $OPTARG
                ;;
        esac
    done

    shift $((OPTIND - 1))
}

main "$@"
