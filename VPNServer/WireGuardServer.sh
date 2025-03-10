#!/bin/bash

#Step 1: Install WireGuard
sudo apt update && sudo apt upgrade -y
sudo apt install wireguard iptables -y

#Step 2: Enable Packet Fowarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

sudo sysctl -p

#Step 3: Generate WireGuard Keys
wg genkey | tee Server_privatekey | wg pubkey > Server_publickey

Server_PrivKey=$(cat Server_privatekey)
Server_PubKey=$(cat Server_publickey)

#Step 4: Create the WireGuard Configuration File

cat <<'EOF' > /etc/wireguard/wg0.conf

[Interface]
PrivateKey = $Server_PrivKey
Address = 10.0.0.1/24
ListenPort = 1194
SaveConfig = true

# NAT for clients to access the internet
PostUp = iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -o wlan0 -j MASQUERADE

EOF

#Step 5: Start WireGuard

sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0

sudo wg > test

if [ -s test ]; then
  echo "Everything is running smoothly you can proceed to make the clients"
else
  echo "Something went wrong check the status of the wg-quick@wg0 server to see what happened"
fi
