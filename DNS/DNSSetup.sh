#!/bin/bash

# Ensure correct usage
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <hostname> <IP_ADDRESS>"
    exit 1
fi

HOSTNAME=$1
IP_ADDRESS=$2
ZONE_FILE="/etc/bind/db.home"

MARKER1="; Name servers"
MARKER2="; Hostname to IP mappings"

# Append the NS and A records to the correct places
sudo sed -i "/$MARKER1/a\\
@	IN	NS	$HOSTNAME.home.
" "$ZONE_FILE"

sudo sed -i "/$MARKER2/a\\
$HOSTNAME	IN	A	$IP_ADDRESS
" "$ZONE_FILE"

# Set correct permissions
sudo chown bind:bind "$ZONE_FILE"
sudo chmod 644 "$ZONE_FILE"

# Validate configuration
sudo named-checkzone home.local "$ZONE_FILE"
if [ $? -eq 0 ]; then
    echo "Zone file validation successful. Restarting BIND..."
    sudo systemctl restart bind9
else
    echo "Zone file validation failed. Check $ZONE_FILE for errors."
    exit 1
fi

echo "Successfully added $HOSTNAME with IP $IP_ADDRESS to $ZONE_FILE"
