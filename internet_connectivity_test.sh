#!/bin/bash
# Script that checks for online connectivity and has the option to send a email once connection is restored.
# 22/03/2019
# Kevin Mostert
#Make sure that mailutils is installed and configured

youremail=your@gmail.com	#Set your email here!

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No colour

# Flag options
has_m_option=false
while getopts :hm opt; do
	case $opt in
		h) echo "Check online connectivity, send mail on successful connection with the -m flag"; exit;;
		m) has_m_option=true ;;
		:) echo "Missing argument for option -$OPTARG"; exit 1;;
		\?) echo "Unknown option -$OPTARG"; exit 1;;
	esac
done

shift $(( OPTIND -1 ))

#Timer function
trycount=0
timer () {
	local sec=00
		while [ $sec -le 59 ]; do
	        	echo -ne " $(printf "%02d""s" $sec)\r"
	        	(( "sec=sec+1" ))
	           	sleep 1
		done
		(( "trycount=trycount+1" ))
	  	sec=00
		echo "Testing...($trycount attempts)"
}

if $has_m_option
then
	if [[ -e "/etc/postfix/main.cf" ]]
	then
		echo "Testing every 1 min ... an email will be sent when successful"
		while true; timer; do ping -c1 unix.com &> /dev/null && break; done && echo "Internet connectivity has resumed" | mail -s "Online $(date +%H:%M\ -\ %d\ %b\ %y)" $youremail &> /dev/null && echo -e "$(date): ${GREEN}Online${NC} ... internet_connection_test stopped" && echo "Internet restored on $(date)" >>/home/"$USER"/scripts.log
		notify-send --urgency=normal "Internet restored" "An email was sent to notify you."
	else
		echo "Please install Postfix to use the m flag"
		exit 1
	fi
else
ping -c3 unix.com &> /dev/null && echo -e "Internet is ${GREEN}Online${NC}" || echo -e "Internet is ${RED}Offline${NC}"
fi
