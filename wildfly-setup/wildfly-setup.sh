#!/bin/bash

# Purpose
# This script is to be run as the ansible user to manage the wildfly setup.
#

#########################################################################################################
# global varibles
#########################################################################################################
ANSIBLE_HOME="$1"

#########################################################################################################
# run ansible playbooks to deploy wildfly
#########################################################################################################

ansible-playbook $ANSIBLE_HOME/jboss_wildfly_playbooks/local_playbooks/1_create-user.yml
ansible-playbook $ANSIBLE_HOME/jboss_wildfly_playbooks/local_playbooks/2_deploy.yml
ansible-playbook $ANSIBLE_HOME/jboss_wildfly_playbooks/local_playbooks/3_start.yml
# difficulties using the cli and ansible to create admin users
# ansible-playbook $ANSIBLE_HOME/jboss_wildfly_playbooks/local_playbooks/4_create_admin.yml
# difficulties compiling through 
# ansible-playbook $ANSIBLE_HOME/jboss_wildfly_playbooks/local_playbooks/5_compile_app1_v01.yml
ansible-playbook $ANSIBLE_HOME/jboss_wildfly_playbooks/local_playbooks/6_deploy_app1_v01.yml