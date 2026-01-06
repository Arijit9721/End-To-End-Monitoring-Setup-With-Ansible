#!/bin/bash

# update the system
sudo apt update && sudo apt upgrade -y

# creating the ansible user
sudo useradd -m -s /bin/bash ansible
sudo usermod -aG sudo ansible   # adding ansible to the sudo group
echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible # making ansible call sudo without password 

# Creating the .ssh directory and setting ownership
mkdir /home/ansible/.ssh
chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh

# setting up the public key for passwordless auth
cat <<EOF > /home/ansible/.ssh/authorized_keys 
"${tls_private_key.ansible_key.public_key_openssh}"
EOF
chmod 600 /home/ansible/.ssh/authorized_keys
