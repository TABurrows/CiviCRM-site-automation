#!/bin/bash

# Script to install letsencrypt certificates

# Warn about DNS first
echo "First step is to ensure you have updated the DNS A record for {{ cert_domain }} to the IP Address $PUBLIC_IP_ADDRESS."

# Await input
read  -n 1 -p "Any key to continue - Ctrl+C to exit:  " mainmenuinput 

# create TLS certificates
sudo certbot certonly -a webroot --webroot-path={{ drupal_web_root }} -m {{ cert_email }} --agree-tos -n --domains={{ cert_domain }}

# move http port 80 config to parent folder
sudo mv /etc/nginx/conf.d/drupal.port80.conf /etc/nginx/drupal.port80.conf

# move http port 443 config to conf.d folder
sudo mv /etc/nginx/drupal.port443.conf /etc/nginx/conf.d/drupal.port443.conf

# restart the web server
sudo systemctl restart nginx