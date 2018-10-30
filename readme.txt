1)  Add the slave ip address in the ansible-setup/slaves.txt file, one per line.
2)  Add the user (with sudoer/root privileges) password to ansible-setup/password.txt.
    This is to facilitate an automatic installation and deployment.
    The password can be removed after the installation is complete.
    This is not a very secure solution, but shoudl be adequate for secure environments.
3)  Run deploy-jboss.sh with sudo or as root.