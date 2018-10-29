#!/bin/bash

# globals
ANSIBLE_UN="ansible"
ANSIBLE_PWD="$ANSIBLE_UN"
SLAVE_FILE="node.txt"
SHOW_EXPECT_SCRIPT_MSG=1
NODE_SETUP_LOG=files_output/node-setup.log

####################################################################################################################
# menu for Ansible setup

while [[ $REPLY != 0 ]]; do

	clear

	echo ""
	echo "-----------------------------------"
	echo "           Ansible Setup"
	echo "-----------------------------------"
	echo "1) Node Setup"
	echo "0) Quit / Exit"
	echo "-----------------------------------"
	read -p "Enter Selection [0-1]: "
	echo "-----------------------------------"
	echo ""

	case $REPLY in
		0)	echo ""
			echo "0) Script Terminated."
			echo ""
			clear
			;;

		1) 	echo ""
			echo "1) Node Setup Selected."

			echo "   output to:  `pwd`/$NODE_SETUP_LOG"
			sleep 5

			echo ""
			./ansible-setup.sh $ANSIBLE_UN $ANSIBLE_PWD $REPLY $SLAVE_FILE | tee `pwd`/$NODE_SETUP_LOG
			chown `logname`.`logname` `pwd`/$NODE_SETUP_LOG
			echo ""
			
			read -n 1 -s -r -p "Press any key to continue"
			;;

		*) 	echo ""
			echo "** Invalid selection. **" >&2
			echo ""
			read -n 1 -s -r -p "Press any key to continue"
			;;
	esac
done	
####################################################################################################################

