#!/bin/bash

# Ensure non-interactive mode for apt
export DEBIAN_FRONTEND=noninteractive

# Update the system
sudo apt update && sudo apt upgrade -y

# Install dependencies for add-apt-repository
sudo apt install -y software-properties-common

# Install ansible and create ansible user
sudo add-apt-repository --yes --update ppa:ansible/ansible 
sudo apt install -y ansible 

sudo useradd -m -s /bin/bash ansible  # create the ansible user and set it as default shell
sudo usermod -aG sudo ansible         # add the ansible user to sudo group

# Making ansible call sudo without password 
echo "ansible ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible
sudo chmod 0440 /etc/sudoers.d/ansible

# Creating the .ssh directory and setting ownership
sudo -u ansible mkdir -p /home/ansible/.ssh
sudo -u ansible chmod 700 /home/ansible/.ssh

# Setting up the private key in ansible user
sudo -u ansible touch /home/ansible/.ssh/id_rsa
cat <<EOF | sudo tee /home/ansible/.ssh/id_rsa
${private_key}
EOF
sudo chown ansible:ansible /home/ansible/.ssh/id_rsa
sudo chmod 600 /home/ansible/.ssh/id_rsa

# Disable strict host key checking
cat <<EOF | sudo tee /home/ansible/.ssh/config
Host *
    StrictHostKeyChecking no
EOF
sudo chown ansible:ansible /home/ansible/.ssh/config
sudo chmod 600 /home/ansible/.ssh/config

# Setting up the ansible files
sudo apt-get install -y git
sudo -u ansible git clone https://github.com/Arijit9721/End-To-End-Monitoring-Setup-With-Ansible.git /home/ansible/Ansible_folder

# Final check
ansible --version
