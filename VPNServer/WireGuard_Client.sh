#!/bin/bash

# Check if they specified name for the client keys
if [ -z "$1" ]; then
  echo -e "Usage: ./WireGuard_Client.sh <client_name>\nPlease specify a name for your client keys."
  exit 1
fi

# Step 1: Generate client keys
wg genkey | tee "${1}_privatekey" | wg pubkey > "${1}_publickey"

# Step 2: Read the generated keys into variables
Client_PrivKey=$(cat "${1}_privatekey")
Client_PubKey=$(cat "${1}_publickey")

# Step 3: Get the Server Public Key (you'll need to provide this in the script)
# You can manually set the server's public key, or fetch it from a file.
Server_PubKey="your_server_public_key_here"

# Step 4: Assign an IP address for the client
Client_IP="10.0.0.$(grep -oP '10.0.0.\K\d+' /etc/wireguard/wg0.conf | sort -n | tail -n 1)"
Client_IP=$((Client_IP + 1))
Client_IP="10.0.0.$Client_IP/32"

# Step 5: Generate the WireGuard configuration file for the client
echo -e "[Interface]" > "/etc/wireguard/${1}_wg0.conf"
echo "PrivateKey = $Client_PrivKey" >> "/etc/wireguard/${1}_wg0.conf"
echo "Address = $Client_IP" >> "/etc/wireguard/${1}_wg0.conf"
echo "DNS = 8.8.8.8" >> "/etc/wireguard/${1}_wg0.conf"
echo -e "\n[Peer]" >> "/etc/wireguard/${1}_wg0.conf"
echo "PublicKey = $Server_PubKey" >> "/etc/wireguard/${1}_wg0.conf"
echo "Endpoint = Your_Raspberry_Pi_Ip:1194" >> "/etc/wireguard/${1}_wg0.conf"
echo "AllowedIPs = 0.0.0.0/0" >> "/etc/wireguard/${1}_wg0.conf"
echo "PersistentKeepalive = 25" >> "/etc/wireguard/${1}_wg0.conf"

# Step 6: Show success message and the contents of the config
echo -e "\nWireGuard client configuration generated:"
cat "/etc/wireguard/${1}_wg0.conf"

echo -e "\nSuccessfully generated the WireGuard configuration file for $1."
