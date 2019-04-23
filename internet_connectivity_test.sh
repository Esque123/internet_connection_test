#!/bin/bash
# Script that checks for online connectivity and has the option to send a email once connection is restored.
# 22/03/2019 
# Kevin Mostert
#Make sure that mailutils is installed and configured

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No colour

# Flag options
has_m_option=false
while getopts :hm opt; do
	case $opt in
		h) echo "Check online connecticity, send mail on sucessfull connection with the -m flag"; exit;;
		m) has_m_option=true ;;
		:) echo "Missing argument for option -$OPTARG"; exit 1;;
		\?) echo "Unknown option -$OPTARG"; exit 1;;
	esac
done

shift $(( OPTIND -1 ))

if $has_m_option
then
	if [[ -e "/etc/postfix/main.cf" ]]
	then
		echo "Testing every 1min ... an email will be sent when sucessfull"
		while true; sleep 1m; do ping -c1 unix.com &> /dev/null && break; done && echo "Internet connectivity has resumed" | mail -s "Online $(date +%H:%M\ -\ %d\ %b\ %y)" "you@gmail.com" &> /dev/null && date && echo -e "${GREEN}Online${NC} ... internet_connection_test stopped" && echo "Internet restored on $(date)" >>/home/"$USER"/scripts.log
	else
		echo "Please install Postfix to use the m flag"
		exit 1
	fi
else
ping -c3 unix.com &> /dev/null && echo -e "Internet is ${GREEN}Online${NC}" || echo -e "Internet is ${RED}Offline${NC}"
fi




