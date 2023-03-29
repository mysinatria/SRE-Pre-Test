#!/bin/bash

# Step 1: Update all packages and apply security updates
sudo apt-get update
sudo apt-get upgrade -y

# Step 2: Disable password authentication for SSH and configure SSH to only allow public key authentication
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Step 3: Configure firewall to only allow traffic on ports 22 and 80
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw enable

# Step 4: Ensure that the server is configured to use a non-root user for the application
sudo adduser myuser
sudo usermod -aG sudo myuser
sudo su - myuser

# Step 5: Disable any unnecessary services
sudo systemctl disable apache2

# Step 6: Remove any unused packages
sudo apt-get autoremove -y

# Step 7: Ensure that the server is configured to use a secure DNS resolver
sudo apt-get install -y systemd-resolved
sudo systemctl enable systemd-resolved
sudo systemctl start systemd-resolved
sudo sed -i 's/#DNS=/DNS=1.1.1.1/' /etc/systemd/resolved.conf
sudo sed -i 's/#FallbackDNS=/FallbackDNS=1.0.0.1/' /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved

# Step 8: Configure web server to use HTTPS with a valid SSL certificate
sudo apt-get install -y certbot
sudo certbot certonly --standalone -d example.com -d www.example.com
sudo sed -i 's/# server_name server_name;/server_name example.com www.example.com;/' /etc/nginx/nginx.conf
sudo sed -i 's/# ssl_certificate/ssl_certificate/' /etc/nginx/nginx.conf
sudo sed -i 's/# ssl_certificate_key/ssl_certificate_key/' /etc/nginx/nginx.conf
sudo systemctl reload nginx

# Step 9: Configure server to use strong password policy and enable password complexity requirements
sudo apt-get install -y libpam-pwquality
sudo sed -i 's/password        \[success=1 default=ignore\]      pam_unix.so obscure sha512/password        [success=1 default=ignore]      pam_unix.so obscure sha512 minlen=8 remember=5/' /etc/pam.d/common-password
