#!/bin/bash

# Purpose
# To manage the deployment of jboss/wildfly to one or more managed (slave) nodes.
#
#########################################################################################################
# check input data
#########################################################################################################
# check that the user has added the ip addresses to the slaves.txt file
func_test_slaves_ip_address(){
    echo ""
    echo "Have you added the slave ip addresses to the following file? "  $PATH_TO_ANSIBLE_SETUP_FILES/$SLAVE_FILE_NAME
    read -p "Enter Selection [y/n]: "
    echo ""

    if [ "$REPLY" = 'y' ] || [ "$REPLY" = 'Y' ]; then
        echo "Thank you."
    elif [ "$REPLY" = 'n' ] || [ "$REPLY" = 'N' ]; then
        echo "IP addresses must be added to $PATH_TO_ANSIBLE_SETUP_FILES/$SLAVE_FILE_NAME."
        echo "exit 1"
        echo ""
        exit 1
    else
        echo "Invalid input."
        echo "exit 1"
        echo ""
        exit 1
    fi
}

# check that the user has added their to the password.txt file
func_test_password_file(){
    echo ""
    echo "Have you added your password to the following file? "  $PATH_TO_ANSIBLE_SETUP_FILES/$PASSWORD_FILE_NAME
    read -p "Enter Selection [y/n]: "
    echo ""

    if [ "$REPLY" = 'y' ] || [ "$REPLY" = 'Y' ]; then
        echo "Thank you."
    elif [ "$REPLY" = 'n' ] || [ "$REPLY" = 'N' ]; then
        echo "Your password must be added to $PATH_TO_ANSIBLE_SETUP_FILES/$PASSWORD_FILE_NAME."    
        echo "exit 1"
        echo ""
        exit 1
    else
        echo "Invalid input."
        echo "exit 1"
        echo ""
        exit 1
    fi    
}

func_test_slaves_ip_address
func_test_password_file

#########################################################################################################
# ansible setup
#########################################################################################################

# This script will install the necessary software on this (master) node, and managed (slave) nodes.
# A user called "ansible", with sudoer privileges, will be created on all nodes.

# variable needed for the ansible setup scripts
PATH_TO_ANSIBLE_SETUP_FILES=`pwd`/ansible-setup
ANSIBLE_SETUP_FILE_NAME=ansible-setup.sh

PATH_TO_SLAVES_FILE=$PATH_TO_ANSIBLE_SETUP_FILES
SLAVE_FILE_NAME=slaves.txt

PATH_TO_PASSWORD_FILE=$PATH_TO_ANSIBLE_SETUP_FILES
PASSWORD_FILE_NAME=password.txt

PATH_TO_LOG_FILES_DIR=$PATH_TO_ANSIBLE_SETUP_FILES/output
MASTER_LOG_FILE_NAME=master-log.txt
PATH_TO_MASTER_LOG_FILE=$PATH_TO_LOG_FILES_DIR/$MASTER_LOG_FILE_NAME

# parameters to ansible setup script
ANSIBLE_UN="ansible"
ANSIBLE_PWD="ansible"
NUM_SLAVES=`grep -v -e '^$' ansible-setup/slaves.txt | wc -l`
echo "NUM_SLAVES="$NUM_SLAVES

SLAVE_FILE=$PATH_TO_PASSWORD_FILE/$PASSWORD_FILE_NAME
echo "slave_file = " $SLAVE_FILE

PROG_USER_SELECTION=
echo "user selection = " $PROG_USER_SELECTION

PROG_USER_PWD=grep -v -e '^$' ansible-setup/password.txt
echo "user pwd = " $PROG_USER_PWD

SLAVE_FILE=$PATH_TO_SLAVES_FILE/$SLAVE_FILE_NAME
echo "slave file = " $SLAVE_FILE

SHOW_EXPECT_SCRIPT_MSG=0
echo "show expect script msg = " $SHOW_EXPECT_SCRIPT_MSG

LOG_FILES_PATH=$PATH_TO_LOG_FILES_DIR

echo "`date`" > /tmp/1-ansible-setup-begin.txt

$PATH_TO_ANSIBLE_SETUP $ANSIBLE_UN $ANSIBLE_PWD $NUM_SLAVES usersel? $PROG_USER_PWD $SLAVE_FILE $SHOW_EXPECT_SCRIPT_MSG $LOG_FILES_PATH | tee -a /tmp/ansible-setup.log

echo "`date`" > /tmp/1-ansible-setup-end.txt

#########################################################################################################

# prepare hadoop for installation, rename and move ansible dir
mv /tmp/ansible-master /tmp/ansible
mv /tmp/ansible /home/ansible/
chown -R ansible.ansible /home/ansible











# setup / format the disk drive (not hadoop formatting).
$PATH_TO_CL_ANSIBLE/init-hdfs.sh

# slave nodes stop here
if [ -z "$SLAVE_NAME_PREFIX" ];then
	# slave nodes will have a null prefix and if a master node cannot have a null prefix, then it
	# should stop also
	exit 1
fi

#########################################################################################################

echo "`date`" > /tmp/2-hadoop-setup-begin.txt

# to be sure ansible owns everything in /home/ansible before starting script
chown -R ansible.ansible /home/ansible

su - ansible -c "$PATH_TO_CL_ANSIBLE/hadoop-setup.sh $HADOOP_VERSION $MASTER_NAME $SLAVE_NAME_PREFIX $PATH_TO_ANSIBLE_DIR $NUM_SLAVES"

echo "`date`" > /tmp/2-hadoop-setup-end.txt

########################################################################################################

echo "`date`" > /tmp/3-boa-compiler-setup-begin.txt

# setup boa items
su - ansible -c "$PATH_TO_CL_ANSIBLE/boa-setup.sh $MASTER_NAME $PATH_TO_ANSIBLE_DIR"

echo "`date`" > /tmp/3-boa-compiler-setup-end.txt

#########################################################################################################

echo "`date`" > /tmp/4-drupal-setup-begin.txt

# ansible to install Drupal (LAMP)
su - ansible -c "$PATH_TO_CL_ANSIBLE/drupal-setup.sh $MASTER_NAME $PATH_TO_CL_ANSIBLE $PATH_TO_ANSIBLE_DIR"

echo "`date`" > /tmp/4-drupal-setup-end.txt

#########################################################################################################
