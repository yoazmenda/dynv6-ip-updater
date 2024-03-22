#!/bin/bash

# Define installation directory
INSTALL_DIR="$HOME/dynv6-ip-updater"

# Clone the repository
git clone https://github.com/yoazmenda/dynv6-ip-updater.git $INSTALL_DIR
if [ $? -ne 0 ]; then
    echo "Error cloning repository."
    exit 1
fi

cd $INSTALL_DIR

# Install Python dependencies
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "Error installing Python dependencies."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating .env file. Please configure it with your dynv6 credentials."
    echo -e "DYNV6_ZONE=your_zone_name\nDYNV6_TOKEN=your_dynv6_token" > .env
else
    echo ".env file already exists. Please ensure it is configured correctly."
fi

# Setup systemd service file
SERVICE_FILE="/etc/systemd/system/dynv6_ip_updater.service"
echo "[Unit]
Description=Dynv6 IP Updater Service

[Service]
User=$USER
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/bin/python3 -m dynv6_ip_updater.updater

[Install]
WantedBy=multi-user.target" | sudo tee $SERVICE_FILE

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable dynv6_ip_updater.service
sudo systemctl start dynv6_ip_updater.service

echo "Installation complete. Dynv6 IP Updater is now running as a service."

