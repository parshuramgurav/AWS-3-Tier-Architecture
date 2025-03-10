#!/bin/bash
set -euo pipefail

# ----------------------------------------------------
# Combined Web Tier and Nginx Setup Script for Amazon Linux
# This script downloads the web-tier code and custom nginx.conf 
# from a GitHub repository using sparse-checkout, installs Node.js,
# builds the web application, installs Nginx, applies the custom configuration,
# and replaces the placeholder for the Internal Load Balancer DNS.
# ----------------------------------------------------

# Check for the Internal Load Balancer DNS argument
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <Internal Load Balancer DNS>"
    exit 1
fi

INTERNAL_LB_DNS="$1"

# Ensure the script is running as ec2-user; if not, switch to it.
if [ "$(whoami)" != "ec2-user" ]; then
    echo "[INFO] Switching to ec2-user..."
    exec sudo -u ec2-user -i "$0" "$@"
fi

# ================================
# CONFIGURATION VARIABLES
# ================================
GITHUB_REPO_URL="https://github.com/<username>/<repo>.git"  # Replace with your GitHub repo URL
WEB_FOLDER_PATH="application-code/web-tier"                # Path to your web-tier code in the repo
NGINX_CONFIG_PATH="application-code/nginx.conf"              # Path to your custom nginx.conf in the repo
WEB_DIR="/home/ec2-user/web-tier"
NGINX_CONF_DIR="/etc/nginx"
TMP_DIR="/tmp/repo_clone"

# ================================
# INSTALLING GIT
# ================================
echo "[INFO] Installing Git if not already installed..."
sudo dnf install -y git

# ================================
# CLONING THE REPOSITORY WITH SPARSE CHECKOUT
# ================================
echo "[INFO] Cloning repository with sparse-checkout for web-tier and nginx.conf..."
rm -rf "$TMP_DIR"
git clone --depth 1 --filter=blob:none --sparse "$GITHUB_REPO_URL" "$TMP_DIR"
cd "$TMP_DIR"
git sparse-checkout set "$WEB_FOLDER_PATH" "$NGINX_CONFIG_PATH"

# ================================
# MOVING THE WEB-TIER CODE
# ================================
echo "[INFO] Moving web-tier code to ${WEB_DIR}..."
mv "$WEB_FOLDER_PATH" "$WEB_DIR"

# ================================
# NODE.JS INSTALLATION & APPLICATION BUILD
# ================================
echo "[INFO] Installing NVM and Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install 16
nvm use 16

echo "[INFO] Installing npm dependencies and building the web application..."
cd "$WEB_DIR"
npm install
# npm audit fix   # Uncomment if you wish to run npm audit fix
npm run build

# ================================
# INSTALLING NGINX
# ================================
echo "[INFO] Installing Nginx..."
sudo yum install -y nginx

# ================================
# CONFIGURING NGINX WITH CUSTOM CONFIGURATION
# ================================
echo "[INFO] Configuring Nginx with custom configuration..."
if [ -f "$NGINX_CONF_DIR/nginx.conf" ]; then
    sudo mv "$NGINX_CONF_DIR/nginx.conf" "$NGINX_CONF_DIR/nginx-backup.conf"
fi
sudo cp "$TMP_DIR/$NGINX_CONFIG_PATH" "$NGINX_CONF_DIR/nginx.conf"

# Replace the placeholder with the provided Internal Load Balancer DNS
echo "[INFO] Replacing placeholder with Internal Load Balancer DNS (${INTERNAL_LB_DNS})..."
sudo sed -i "s/<Your-Internal-LoadBalancer-DNS>/${INTERNAL_LB_DNS}/g" "$NGINX_CONF_DIR/nginx.conf"

# ================================
# CLEANING UP TEMPORARY FILES
# ================================
cd ..
rm -rf "$TMP_DIR"

# ================================
# SETTING PERMISSIONS
# ================================
sudo chown -R ec2-user:ec2-user /home/ec2-user/web-tier
sudo chmod -R 755 /home/ec2-user
sudo chmod -R 755 "$NGINX_CONF_DIR"

# ================================
# RESTARTING NGINX
# ================================
echo "[INFO] Restarting Nginx..."
sudo service nginx restart
sudo chkconfig nginx on

echo "[INFO] Web tier and Nginx setup complete!"