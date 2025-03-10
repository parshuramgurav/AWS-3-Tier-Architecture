#!/bin/bash
set -euo pipefail

#-------------------------------------------------
# Optimized Setup Script for Amazon Linux
# This script installs MySQL client, downloads a specific folder 
# from a GitHub repository via sparse-checkout, and sets up Node.js
# with the provided npm commands.
#-------------------------------------------------

# Logging functions
log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

# Ensure the script is run as ec2-user
if [ "$(whoami)" != "ec2-user" ]; then
    log_info "Switching to ec2-user..."
    exec sudo -u ec2-user -i "$0" "$@"
fi

#===============================
# CONFIGURATION VARIABLES
#===============================
GITHUB_REPO_URL="https://github.com/<username>/<repo>.git"  # Replace with your GitHub repo URL
FOLDER_PATH="application-code/app-tier"                    # Replace with the specific folder path
APP_DIR="/home/ec2-user/app-tier"

#===============================
# INSTALLING MYSQL CLIENT
#===============================
log_info "Installing MySQL client..."
if ! command -v mysql &> /dev/null; then
    wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm -O /tmp/mysql-release.rpm
    sudo dnf install -y /tmp/mysql-release.rpm
    sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
    sudo dnf install -y mysql-community-client
    rm -f /tmp/mysql-release.rpm
fi
mysql --version

#===============================
# DOWNLOAD SPECIFIC FOLDER FROM GITHUB
#===============================
log_info "Ensuring Git is installed..."
sudo dnf install -y git

log_info "Cloning repository (sparse checkout) and downloading the folder..."
cd /home/ec2-user
git clone --depth 1 --filter=blob:none --sparse "$GITHUB_REPO_URL"
REPO_NAME=$(basename "$GITHUB_REPO_URL" .git)
cd "$REPO_NAME"
git sparse-checkout set "$FOLDER_PATH"

# Move the specific folder to the target location and clean up
mv "$FOLDER_PATH" ../app-tier
cd ..
rm -rf "$REPO_NAME"
log_info "Folder downloaded to ${APP_DIR}."

# Set proper ownership and permissions
sudo chown -R ec2-user:ec2-user "$APP_DIR"
sudo chmod -R 755 "$APP_DIR"

#===============================
# INSTALLING NODEJS VIA NVM
#===============================
log_info "Installing NVM (Node Version Manager)..."
if [ ! -d "/home/ec2-user/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# Load nvm (adjust NVM_DIR if necessary)
export NVM_DIR="/home/ec2-user/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

log_info "Installing Node.js version 16..."
nvm install 16
nvm use 16

log_info "Installing pm2 globally..."
npm install -g pm2

#===============================
# INSTALLING PROJECT DEPENDENCIES
#===============================
log_info "Installing npm dependencies in ${APP_DIR}..."
cd "$APP_DIR"
npm install
npm audit fix

log_info "Setup complete!"