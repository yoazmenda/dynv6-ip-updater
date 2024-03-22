#!/bin/bash

# Check if Python3 and pip are installed
if ! command -v python3 &> /dev/null || ! command -v pip &> /dev/null; then
    echo "Python3 and pip are required but could not be found. Please install them before continuing."
    exit 1
fi

# Define installation directory
INSTALL_DIR="$HOME/dynv6-ip-updater"

# Ensure the installation directory is clean
if [ -d "$INSTALL_DIR" ]; then
    read -p "Installation directory already exists. Delete and proceed? [y/N] " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        rm -rf "$INSTALL_DIR"
    else
        echo "Installation aborted."
        exit 1
    fi
fi

# Clone the repository
git clone https://github.com/yoazmenda/dynv6-ip-updater.git $INSTALL_DIR
if [ $? -ne 0 ]; then
    echo "Error cloning repository."
    exit 1
fi

cd $INSTALL_DIR

# Install Python dependencies
pip install -r requirements.txt --user
if [ $? -ne 0 ]; then
    echo "Error installing Python dependencies."
    exit 1
fi

# Prompt for Dynv6 credentials
read -p "Enter your Dynv6 Zone: " dynv6_zone
read -p "Enter your Dynv6 Token: " dynv6_token

# Setup systemd service file (prompt for sudo password here)
SERVICE_FILE="/etc/systemd/system/dynv6_ip_updater.service"
echo "[Unit]
Description=Dynv6 IP Updater Service

[Service]
User=$USER
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/bin/python3 $INSTALL_DIR/updater.py $dynv6_zone $dynv6_token

[Install]
WantedBy=multi-user.target" | sudo tee $SERVICE_FILE > /dev/null

if [ $? -ne 0 ]; then
    echo "Error setting up the systemd service file. Are you sure you have sudo privileges?"
    exit 1
fi

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable dynv6_ip_updater.service
sudo systemctl start dynv6_ip_updater.service

echo "Installation complete. Dynv6 IP Updater is now running as a service."

