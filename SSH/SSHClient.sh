#!/bin/bash

# Define variables
PI_USER="pi" # Change this to your Pi's username
PI_HOST="raspberrypi.local"  # Change this to your Pi's IP if needed
SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/id_rsa"

# Ensure SSH directory exists
mkdir -p $SSH_DIR
chmod 700 $SSH_DIR

# Generate SSH key pair (if not already present)
if [ ! -f "$SSH_KEY" ]; then
    echo "Generating SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f $SSH_KEY -N ""
else
    echo "SSH key already exists, skipping key generation."
fi

# Copy the public key to Raspberry Pi
echo "Copying SSH key to Raspberry Pi..."
ssh-copy-id -i "$SSH_KEY.pub" "$PI_USER@$PI_HOST"

# Test SSH connection
echo "Testing SSH connection..."
ssh -o StrictHostKeyChecking=no "$PI_USER@$PI_HOST" "echo 'SSH key authentication successful!'"

echo "SSH key authentication setup complete! Now you can log in without a password:"
echo "ssh $PI_USER@$PI_HOST"
