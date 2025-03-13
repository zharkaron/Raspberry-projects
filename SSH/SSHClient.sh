#!/bin/bash

# Set the correct user and host
USER="your_normal_user"  # Replace this with your normal username (not root)
PI_USER="pi"  # Raspberry Pi username
PI_HOST="raspberry.local"  # Raspberry Pi IP address

# Set the correct home directory for the user
HOME_DIR=$(eval echo ~$USER)  # This will get the home directory of your normal user

# SSH directory and key file locations
SSH_DIR="$HOME_DIR/.ssh"
SSH_KEY="$SSH_DIR/id_rsa"
PUBLIC_KEY="$SSH_KEY.pub"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

# Ensure the SSH directory exists for the normal user
mkdir -p $SSH_DIR
chmod 700 $SSH_DIR

# Generate SSH key pair if not already present
if [ ! -f "$SSH_KEY" ]; then
    echo "Generating SSH key pair for user $USER..."
    ssh-keygen -t rsa -b 4096 -f $SSH_KEY -N ""  # No passphrase
else
    echo "SSH key pair already exists for user $USER. Skipping key generation."
fi

# Check if the public key exists
if [ ! -f "$PUBLIC_KEY" ]; then
    echo "Public key not found! Please check if key generation was successful."
    exit 1
fi

# Copy the public key to the Raspberry Pi
echo "Copying public key to Raspberry Pi..."
ssh-copy-id -i "$PUBLIC_KEY" "$PI_USER@$PI_HOST"

# Check if ssh-copy-id was successful
if [ $? -ne 0 ]; then
    echo "Failed to copy public key. Please ensure the Raspberry Pi is reachable and the credentials are correct."
    exit 1
fi

# Verify SSH key authentication
echo "Testing SSH key authentication..."
ssh -o StrictHostKeyChecking=no -v "$PI_USER@$PI_HOST" "echo 'SSH key authentication successful!'"

if [ $? -eq 0 ]; then
    echo "SSH key authentication is working!"
else
    echo "SSH key authentication failed. Check the output above for more details."
fi

echo "SSH key authentication setup complete!"
echo "You can now log in without a password by running:"
echo "ssh $PI_USER@$PI_HOST"
