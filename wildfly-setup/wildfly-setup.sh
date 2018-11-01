#!/bin/bash

# Purpose
# This script is to be run as the ansible user to manage the wildfly setup.
#

#########################################################################################################
# global varibles
#########################################################################################################
ANSIBLE_HOME="$1"
ANSIBLE_NAME="$2"
#########################################################################################################
# run ansible playbooks to deploy wildfly
#########################################################################################################

su - $ANSIBLE_NAME -c "ansible-playbook $ANSIBLE_HOME/jboss_wildfly_playbooks/local_playbooks/0a_compressed_file_setup.yml" # | tee -a /tmp/wildfly-setup.log
su - $ANSIBLE_NAME -c "ansible-playbook $ANSIBLE_HOME/jboss_wildfly_playbooks/local_playbooks/0b_compressed_file_setup.yml" # | tee -a /tmp/wildfly-setup.log
su - $ANSIBLE_NAME -c "ansible-playbook $ANSIBLE_HOME/jboss_wildfly_playbooks/local_playbooks/1_create-user.yml" # | tee -a /tmp/wildfly-setup.log
su - $ANSIBLE_NAME -c "ansible-playbook $ANSIBLE_HOME/jboss_wildfly_playbooks/local_playbooks/2_deploy.yml" # | tee -a /tmp/wildfly-setup.log
su - $ANSIBLE_NAME -c "ansible-playbook $ANSIBLE_HOME/jboss_wildfly_playbooks/local_playbooks/3_start.yml" # | tee -a /tmp/wildfly-setup.log

# difficulties using the cli and ansible to create admin users
# ansible-playbook $ANSIBLE_HOME/jboss_wildfly_playbooks/local_playbooks/4_create_admin.yml
# difficulties compiling through 
# ansible-playbook $ANSIBLE_HOME/jboss_wildfly_playbooks/local_playbooks/5_compile_app1_v01.yml

su - $ANSIBLE_NAME -c "ansible-playbook $ANSIBLE_HOME/jboss_wildfly_playbooks/local_playbooks/6_deploy_app1_v01.yml" # | tee -a /tmp/wildfly-setup.log