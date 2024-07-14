#!/bin/bash

# Make the script non-interactive
export DEBIAN_FRONTEND=noninteractive

# Set NEEDRESTART_SUSPEND to a non-empty value and export it
export NEEDRESTART_SUSPEND=1

# Set NEEDRESTART_MODE to either “automatic” or “list”
export NEEDRESTART_MODE=automatic

# Disable the dpkg needrestart hook if it exists
[ -f /etc/dpkg/dpkg.cfg.d/needrestart ] && mv /etc/dpkg/dpkg.cfg.d/needrestart /etc/dpkg/dpkg.cfg.d/needrestart.disabled

echo "* libraries/restart-without-asking boolean true" | sudo debconf-set-selections

# Update and upgrade the system
sudo apt-get update -y
sudo apt-get upgrade -y -o 

# Install Ansible for Ubuntu 22
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y ansible

# Install Python3-pip
sudo apt install -y python3-pip

# Install Boto3
python3 -m pip install boto3

# Install AWS CLI
sudo apt update -y
sudo apt install -y curl unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install -y terraform

# Define the configuration content for ansible.cfg file
CONFIG_CONTENT="[defaults]
inventory      = /etc/ansible/hosts
sudo_user      = root
host_key_checking = False
retry_files_enabled = True
retry_files_save_path = ~/mtc-terransible/.ansible-retry

[inventory]
enable_plugins = host_list, script, auto, yaml, ini, toml, aws_ec2, virtualbox, constructed"

# Specify the ansible.cfg file path
ANSIBLE_CFG_PATH="/etc/ansible/ansible.cfg"

# Backup existing ansible.cfg file if it exists
if [ -e "$ANSIBLE_CFG_PATH" ]; then
    sudo cp "$ANSIBLE_CFG_PATH" "$ANSIBLE_CFG_PATH.bak"
fi

# Write the configuration content to ansible.cfg
echo "$CONFIG_CONTENT" | sudo tee "$ANSIBLE_CFG_PATH" > /dev/null

echo "Configuration completed. Your original ansible.cfg is backed up as ansible.cfg.bak."

# Specify the content to be added to Ansible hosts file
HOSTS_CONTENT="[hosts]
localhost"

# Specify the hosts file path
HOSTS_FILE="/etc/ansible/hosts"

# Backup existing hosts file if it exists
if [ -e "$HOSTS_FILE" ]; then
    sudo cp "$HOSTS_FILE" "$HOSTS_FILE.bak"
fi

# Append the content to the hosts file
echo "$HOSTS_CONTENT" | sudo tee -a "$HOSTS_FILE" > /dev/null

echo "Content added to $HOSTS_FILE. Your original hosts file is backed up as $HOSTS_FILE.bak."

# Restore needrestart hook if it was disabled
[ -f /etc/dpkg/dpkg.cfg.d/needrestart.disabled ] && mv /etc/dpkg/dpkg.cfg.d/needrestart.disabled /etc/dpkg/dpkg.cfg.d/needrestart

# Ensure script terminates correctly and restores needrestart hook
#trap '[ -f /etc/dpkg/dpkg.cfg.d/needrestart.disabled ] && mv /etc/dpkg/dpkg.cfg.d/needrestart.disabled /etc/dpkg/dpkg.cfg.d/needrestart' EXIT