#!/bin/bash

# update the system
sudo apt update && sudo apt upgrade -y

# install ansible and create ansible user
sudo apt install ansible -y
sudo useradd -m -s /bin/bash ansible  # create the ansible user and set it as default shell
sudo usermod -aG sudo ansible         # add the ansible user to sudo group
echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ansible # making ansible call sudo without password 

# Creating the .ssh directory and setting ownership
mkdir /home/ansible/.ssh
chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh

# setting up the private key in ansible user
cat <<EOF > /home/ansible/.ssh/id_rsa    # safely adding the key to ansible
${tls_private_key.ansible_key.private_key_pem}
EOF
chmod 600 /home/ansible/.ssh/id_rsa
cat <<EOF > /home/ansible/.ssh/config    # disable strict host key checking
Host *
    StrictHostKeyChecking no
EOF
chown ansible:ansible /home/ansible/.ssh/config
chmod 600 /home/ansible/.ssh/config
