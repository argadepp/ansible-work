#!/bin/bash
# Update the package repository and install required packages
yum update -y  # For Amazon Linux
apt-get update -y  # For Ubuntu

# Set 'PasswordAuthentication yes' in the SSH config file
# This will add it if it does not exist, or modify it if it does.
if grep -q "^PasswordAuthentication" /etc/ssh/sshd_config; then
    sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
else
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
fi

# Reload the SSH daemon to apply the changes
systemctl restart sshd

# Create a user with a password
USERNAME="pratik"
PASSWORD="pratik"

# Create the user and set the password
useradd $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd

# Ensure the user can use sudo without a password
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# (Optional) Allow EC2 instance access using password
# Uncomment this block to disable requiring a key for SSH access
# sudo sed -i '/^ChallengeResponseAuthentication no/c\ChallengeResponseAuthentication yes' /etc/ssh/sshd_config

# Reload sshd again after sudo and user changes
systemctl restart sshd
