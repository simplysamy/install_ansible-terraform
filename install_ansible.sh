#!/bin/bash

# Install Ansible for ubuntu 22
sudo apt update -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y ansible

# Install Python3-pip
sudo apt install python3-pip -y

# Install Boto3
python3 -m pip install boto3

# Install AWS CLI
sudo apt update -y
sudo apt install curl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install

# install terraform
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install terraform -y



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

# Specify the content to be added to ansibles hosts file
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



