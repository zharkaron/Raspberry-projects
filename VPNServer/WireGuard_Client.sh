#!/bin/bash

# Check if client name is provided
if [ -z "$1" ]; then
  echo "Usage: ./WireGuard_Client_Setup.sh <client_name>"
  echo "Please specify a name for your client keys."
  exit 1
fi

# Step 1: Generate Client Keys
wg genkey | tee "${1}_privatekey" | wg pubkey > "${1}_publickey"

Client_PrivKey=$(cat "${1}_privatekey")
Client_PubKey=$(cat "${1}_publickey")

# Step 2: Extract the Server Public Key from the Server Configuration
Server_PubKey=$(cat "Server_publickey")

# Step 3: Find the Highest Used IP Address from the Server Configuration
# The IP address format is assumed to be "10.0.0.x/32", we will extract the highest number and increment it.
highest_ip=$(sudo grep -oP "10\.0\.0\.\d+" /etc/wireguard/wg0.conf | sort -t. -k4 -n | tail -n 1)

# Determine the next available IP address
if [ -z "$highest_ip" ]; then
  next_ip="10.0.0.2"
else
  # Extract the last octet and increment it by 1
  next_ip_octet=$(echo "$highest_ip" | awk -F. '{print $4 + 1}')
  next_ip="10.0.0.$next_ip_octet"
fi

# Step 4: Create the Client Configuration File
sudo bash -c "cat <<EOF > ${1}_wg0.conf
[Interface]
PrivateKey = $Client_PrivKey
Address = $next_ip/24
DNS = 8.8.8.8

[Peer]
PublicKey = $Server_PubKey
Endpoint = Your_Raspberry_Pi_IP:1194
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF"

# Step 5: Add the Client to the Server Configuration
sudo bash -c "cat <<EOF >> /etc/wireguard/wg0.conf

[Peer]
PublicKey = $Client_PubKey
AllowedIPs = $next_ip/32
EOF"

sudo systemctl restart wg-quick@wg0

echo "Client configuration file '${1}_wg0.conf' created."
echo "Client added to server configuration with IP address $next_ip."
