#!/bin/bash
# Script that checks for online connectivity and has the option to send a email once connection is restored.
# 22/03/2019
# Kevin Mostert
#Make sure that mailutils is installed and configured

#Set your email here!
#############################################
youremail="your_mail_here@gmail.com"
#############################################

#Colours:
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No colour

#######################################		FUNCTIONS	####################################
# Help function
function help {
cat << _HELP_

Internet connectivity test (v1) - A script that will check the status of
your online connection by pinging unix.com.

Usage:
internet_connectivity_test.sh [Option]

Options:

-h	Display this help message.
-m	Will send and email to the specified email in this script on successful
	connection.
	If you want to use this flag you need to open this script and set your
	email address on line 9.

-Kevin Mostert
_HELP_

}

# Timer function
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
		echo "Testing...($trycount attempts)."
}

# Ping function
function pingunix {
	ping -c1 unix.com &> /dev/null
}

# Check if mail has been specified function
function mailsetcheck {
	if [[ "$youremail" == "your_mail_here@gmail.com" ]]
	then
		echo "Email Address Undefined: Please set your email before you can use the -m flag."
		exit 1
	fi
}
########################################	FLAG OPTIONS:		###########################################

has_m_option=false
while getopts hm opt; do
	case "$opt" in
		h)
			help
			exit;;
		m)
			has_m_option=true ;;
		\?)
			help
			exit 1;;
	esac
done

shift $(( OPTIND -1 ))

########################################	MAIN SCRIPT		############################################
# Mail Option:
if $has_m_option
then
	# Verify that postfix is installed. Doesn't make a check that postfix and ssmtp is setup and configured correctly.
	if [[ -e $(command -v postfix) ]]
	then
		mailsetcheck
		echo "Testing every 1 min ... an email will be sent to $youremail when successful."
		while true
		do	#Start 60s timer, ping and break on success, else repeat.
			timer
			pingunix && break
		done
		echo "Internet connectivity has resumed, sending email to $youremail."
		echo "Internet connectivity has resumed" | mail -s "Online $(date +%H:%M\ -\ %d\ %b\ %y) after $trycount attempts" "$youremail"
		echo -e "$(date): ${GREEN}Online${NC} ... internet_connection_test stopped."
		echo "Internet restored on $(date) after $trycount attempts." >> /home/"$USER"/scripts.log
		notify-send --urgency=normal "Internet restored" "An email was sent to notify you."
	else
		echo "Please install Postfix, and make sure it is configured correctly, to use the -m flag."
		exit 1
	fi
else
# Default - No Option Specified
	pingunix && echo -e "Internet is ${GREEN}Online${NC}." || echo -e "Internet is ${RED}Offline${NC}."
fi
