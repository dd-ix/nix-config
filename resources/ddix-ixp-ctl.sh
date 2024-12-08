#!/bin/sh

PREFIX=ddix-ixp-
UNITS="build
       rdns
       sflow
       rs@ixp-rs01.dd-ix.net
       rs@ixp-rs02.dd-ix.net
       sw@ixp-c2-sw01.dd-ix.net
       sw@ixp-cc-sw01.dd-ix.net
       commit"

#ANSI_BLUE=$(echo -e "\e[34m")
ANSI_GREEN=$(echo -e "\e[42;37m")
ANSI_YELLOW=$(echo -e "\e[43;30m")
ANSI_RED=$(echo -e "\e[5m\e[101;37m")
ANSI_BOLD=$(echo -e "\e[1m")
ANSI_NORMAL=$(echo -e "\e[0m")

unit_show() {
    echo
    echo "${ANSI_BOLD}UNIT STATES${ANSI_NORMAL}"
    echo
    for unit in ${UNITS}; do
        state=$(systemctl show "$PREFIX$unit" | grep ActiveState | cut -d= -f2)
        case "$state" in
        active | activating | deactivating)
            echo -n "${ANSI_YELLOW}"
            ;;
        inactive)
            echo -n "${ANSI_GREEN}"
            ;;
        *)
            echo -n "${ANSI_RED}"
            ;;
        esac
        echo -n " $unit ${ANSI_NORMAL} "
    done
    echo
}

kill_show() {
    if [ -z "$(find /var/lib/arouteserver/kill -mindepth 1 -maxdepth 1 -type f 2>/dev/null)" ]; then
        return
    fi

    echo
    echo "${ANSI_BOLD}KILL SWITCHES${ANSI_NORMAL}"
    echo
    for fn in /var/lib/arouteserver/kill/*; do
        name=$(basename "${fn}")
        echo -n "${ANSI_RED} $name ${ANSI_NORMAL} "
    done
    echo
}

unit_show
kill_show
