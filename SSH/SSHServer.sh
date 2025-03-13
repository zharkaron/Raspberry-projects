#!/bin/bash

# Update and install SSH server
echo "Updating system and installing OpenSSH server..."
sudo apt update && sudo apt install -y openssh-server

# Enable and start SSH service
echo "Enabling and starting SSH service..."
sudo systemctl enable ssh
sudo systemctl start ssh

# Configure SSH settings
SSH_CONFIG="/etc/ssh/sshd_config"

echo "Configuring SSH settings..."
sudo sed -i 's/#Port 22/Port 22/' $SSH_CONFIG  # Ensure default port is set
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' $SSH_CONFIG  # Disable root login
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' $SSH_CONFIG  # Ensure password authentication is enabled

# Restart SSH service
echo "Restarting SSH service..."
sudo systemctl restart ssh

# Display IP address
IP_ADDR=$(hostname -I | awk '{print $1}')
echo "SSH server is running!"
echo "You can connect using: ssh pi@$IP_ADDR"

echo "SSH setup completed!"
