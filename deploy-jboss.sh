#!/bin/bash

# Purpose
# To manage the deployment of jboss/wildfly to one or more managed (slave) nodes.
#
#########################################################################################################

# gather global vals
PATH_TO_ANSIBLE_SETUP_FILES=./ansible-setup
ANSIBLE_SETUP_FILE_NAME=ansible-setup.sh

PATH_TO_SLAVES_FILE=$PATH_TO_ANSIBLE_SETUP_FILES
SLAVE_FILE_NAME=slaves.txt
PASSWORD_FILE_NAME=password.txt



# MASTER_IP_ADDRESS=`hostname --ip-address`
# NUM_SLAVES=$3

# PATH_TO_CL_TMP=/tmp/ansible-master/cloudlab
# PATH_TO_ANSIBLE_DIR=/home/ansible/ansible


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

# install the necessary software on this (master) node, and managed (slave) nodes.
# a user called "ansible", with sudoer privileges, will be created on all nodes.

echo "`date`" > /tmp/1-ansible-setup-begin.txt

$PATH_TO_ANSIBLE_SETUP  $MASTER_IP_ADDRESS $NUM_SLAVES | tee -a /tmp/ansible-setup.log

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
