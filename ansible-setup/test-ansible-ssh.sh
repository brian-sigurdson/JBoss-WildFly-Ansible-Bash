#!/bin/bash

# Author:       Brian Sigurdson sigurdson.brian@gmail.com
# Date:         2018-10-30
# Description:  Test that passwordless ssh exists for user ansible from the master to each
# 				node in the cluster, in cluding the master node itself.

####################################################################################################################

#PROG_NAME="$0"
#PROG_BASE_NAME=$(basename $0)
ANSIBLE_UN="$1"
RUN_ON="$2"
LOG_FILES_PATH="$3"
PATH_TO_ANSIBLE_SETUP_FILES_DIR="$4"
#PROG_USER=`logname`
HOST_IP=`hostname -i`
HOST_NAME=`hostname`

# call the expect script
if (( $RUN_ON == 0 )); then
	# run on the master
	echo ""
	echo "Processing: $HOST_IP"
	echo "$PATH_TO_ANSIBLE_SETUP_FILES_DIR/expect-script-test-ssh.sh $ANSIBLE_UN $HOST_IP | sudo tee $LOG_FILES_PATH/ssh-test-$HOST_IP"
	$PATH_TO_ANSIBLE_SETUP_FILES_DIR/expect-script-test-ssh.sh $ANSIBLE_UN $HOST_IP | sudo tee $LOG_FILES_PATH/ssh-test-"$HOST_IP"

else
	# run on the slaves
	echo ""
	for SLAVE in `cat slaves.txt`; do
		echo ""
		echo "Processing: $SLAVE"
		echo "$PATH_TO_ANSIBLE_SETUP_FILES_DIR/expect-script-test-ssh.sh $ANSIBLE_UN $SLAVE | sudo tee $LOG_FILES_PATH/ssh-test-$SLAVE"
		$PATH_TO_ANSIBLE_SETUP_FILES_DIR/expect-script-test-ssh.sh $ANSIBLE_UN $SLAVE | sudo tee $LOG_FILES_PATH/ssh-test-"$SLAVE"
		echo ""
	done
fi
