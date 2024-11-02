#!/bin/bash

# Step 1: Clean up any previous Nginx installation and processes
echo "Removing old Nginx installation and stopping any running processes..."
rm -rf /usr/local/nginx/
pkill nginx || echo "No Nginx process running"

# Step 2: Install build dependencies
echo "Installing build dependencies..."
apt update
apt install -y libpcre3 libpcre3-dev zlib1g zlib1g-dev openssl libssl-dev libxslt1-dev libgd-dev libgeoip-dev

# Step 3: Add the bionic-security repository and its GPG key if necessary
if ! grep -q "bionic-security main" /etc/apt/sources.list; then
    echo "Adding bionic-security repository to sources.list..."
    echo "deb http://security.ubuntu.com/ubuntu bionic-security main" | sudo tee -a /etc/apt/sources.list
fi

# Step 4: Add the missing GPG key (skip if it already exists)
KEY_FILE="/etc/apt/trusted.gpg.d/ubuntu_bionic_security.gpg"
if [ ! -f "$KEY_FILE" ]; then
    echo "Adding missing GPG key for bionic-security..."
    curl -fsSL https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3B4FE6ACC0B21F32 | sudo gpg --dearmor -o "$KEY_FILE"
else
    echo "GPG key for bionic-security already exists."
fi

# Step 5: Update the package list and install libssl1.0-dev
echo "Updating package lists and installing libssl1.0-dev..."
sudo apt update
sudo apt-get install -y libssl1.0-dev

# Step 6: Install Nginx using dpkg
echo "Installing Nginx .deb packages..."
sudo dpkg -i deb/*.deb

# Step 7: Start and enable Nginx to run on boot
echo "Starting and enabling Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Step 8: Confirm Nginx installation and service status
echo "Nginx installation complete. Service status:"
sudo systemctl status nginx
