Odoo 16 Installation Script

This script automates the installation of Odoo 16 on a Ubuntu 22.04 server.

Prerequisites
Ubuntu 22.04 server with sudo user
Internet connectivity

How to use the script
1. Copy the script to your server:
   wget https://github.com/PeiferIT/install_odoo16.sh
2. Make the script executable:
   chmod +x odoo16_install.sh
3. Run the script:
   sudo ./odoo16_install.sh

What this script does
1. Installs system dependencies
2. Creates a PostgreSQL user and database for Odoo
3. Creates a system user for Odoo
4. Installs and configures virtualenv and Odoo dependencies
5. Downloads and installs Odoo 16 from GitHub
6. Configures Odoo 16
7. Creates a systemd service file to start Odoo on boot

Notes
The Odoo instance will be available at http://localhost:8069
Odoo logs will be available at /var/log/odoo16/odoo16.log
The Odoo service can be started, stopped, and restarted with systemctl start odoo16, systemctl stop odoo16, and systemctl restart odoo16, respectively.