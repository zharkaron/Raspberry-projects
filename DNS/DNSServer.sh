#!/bin/bash

# Update & install BIND9
sudo apt update && sudo apt upgrade -y
sudo apt install bind9 -y

# Configure named.conf.options
sudo tee /etc/bind/named.conf.options <<EOF
options {
	directory "/var/cache/bind";

	recursion yes;
	allow-query { any; };
	forwarders {};

	listen-on { any; };
	listen-on-v6 { any; };
};
EOF

# Configure named.conf.local
sudo tee /etc/bind/named.conf.local <<EOF
zone "home" {
	type master;
	file "/etc/bind/db.home";
};
EOF

# Configure db.home (zone file)
sudo tee /etc/bind/db.home <<EOF
\$TTL 86400
@	IN	SOA	ns1.home. root.home. (
		1	; Serial
		604800	; Refresh
		86400	; Retry
		2419200	; Expire
		86400 )	; Negative Cache TTL

; Name servers

; Hostname to IP mappings
EOF

# Set correct permissions for BIND9
sudo chown bind:bind /etc/bind/db.home
sudo chmod 644 /etc/bind/db.home

# Restart and enable BIND9
sudo systemctl restart bind9
sudo systemctl enable bind9

# Test configuration
sudo named-checkconf
sudo named-checkzone home.local /etc/bind/db.home
