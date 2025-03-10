#!/bin/bash

# Check if client name is provided
if [ -z "$1" ]; then
  echo "Usage: ./WireGuard_Client_Setup.sh <client_name> \nPlease specify a name for your client keys."
  exit 1
fi

# Step 1: Generate Client Keys
wg genkey | tee "${1}_privatekey" | wg pubkey > "${1}_publickey"

Client_PrivKey=$(cat "${1}_privatekey")
Client_PubKey=$(cat "${1}_publickey")

# Step 2: Extract the Server Public Key from the Server Configuration
Server_PubKey=$(sudo grep -oP "(?<=PublicKey = ).*" /etc/wireguard/wg0.conf)

# Step 3: Create the Client Configuration File

sudo bash -c "cat <<EOF > /etc/wireguard/${1}_wg0.conf
[Interface]
PrivateKey = $Client_PrivKey
Address = 10.0.0.2/24
DNS = 8.8.8.8

[Peer]
PublicKey = $Server_PubKey
Endpoint = Your_Raspberry_Pi_IP:1194
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF"

# Step 4: Enable and Start WireGuard on Client
sudo systemctl enable wg-quick@${1}_wg0
sudo systemctl start wg-quick@${1}_wg0

# Check the status of WireGuard on the client
sudo wg > test

if [ -s test ]; then
  echo "Client configuration complete, and the connection is up!"
else
  echo "Client setup failed. Check the client logs and verify configuration."
  exit 1
fi

# Clean up the test file
rm -f test
