#!/bin/bash

set -e
set -x

# Update and upgrade system packages
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install python3-pip npm nodejs wget python3-dev python3-venv python3-wheel libxml2-dev libpq-dev libjpeg8-dev liblcms2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev build-essential git libssl-dev libffi-dev libmysqlclient-dev libjpeg-dev libblas-dev libatlas-base-dev -y

# Install PostgreSQL
sudo apt install postgresql -y

# Create PostgreSQL user
sudo su - postgres -c "createuser -s odoo16"

# Create Odoo16 user
sudo useradd -m -d /opt/odoo16 -U -r -s /bin/bash odoo16

# Download and install required packages
sudo wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb
sudo chmod +x wkhtmltox_0.12.6-1.focal_amd64.deb
sudo apt install ./wkhtmltox_0.12.6-1.focal_amd64.deb -y

# Switch to Odoo16 user and install Odoo
sudo -u odoo16 git clone https://www.github.com/odoo/odoo --depth 1 --branch 16.0 /opt/odoo16/odoo
sudo -u odoo16 git clone https://www.github.com/CybroOdoo/CybroAddons --depth 1 --branch 16.0 /opt/odoo16/cybro

cd /opt/odoo16
sudo -u odoo16 bash -c "cd /opt/odoo16 && python3 -m venv odoo16-venv"
sudo -u odoo16 bash -c "source odoo16-venv/bin/activate && pip3 install wheel"
sudo -u odoo16 bash -c "source odoo16-venv/bin/activate && pip3 install -r odoo/requirements.txt"
sudo -u odoo16 bash -c "source odoo16-venv/bin/activate && pip3 install paramiko"
sudo -u odoo16 bash -c "mkdir /opt/odoo16/custom-addons"
sudo -u odoo16 bash -c "mkdir /opt/odoo16/backups"

cd

# Create Odoo configuration file
sudo touch /etc/odoo16.conf
sudo chown odoo16: /etc/odoo16.conf
sudo chmod 640 /etc/odoo16.conf
sudo cat > /etc/odoo16.conf <<EOF
[options]
; This is the password that allows database operations:
admin_passwd = admin_password
db_host = False
db_port = False
db_user = odoo16
db_password = False
xmlrpc_port = 8069
logfile = /var/log/odoo16/odoo.log
addons_path = /opt/odoo16/odoo/addons,/opt/odoo16/custom-addons,/opt/odoo16/cybro
# proxy_mode = True
# dbfilter = 
# list_db = False
limit_memory_hard = 1677721600
limit_memory_soft = 629145600
limit_request = 8192
limit_time_cpu = 600
limit_time_real = 1200
max_cron_threads = 1
workers = 8
EOF

# Create log directory and change ownership
sudo mkdir /var/log/odoo16
sudo chown odoo16: /var/log/odoo16

# Create systemd service file
sudo cat > /etc/systemd/system/odoo16.service <<EOF
[Unit]
Description=Odoo16
Requires=postgresql.service
After=network.target postgresql.service

[Service]
Type=simple
SyslogIdentifier=odoo16
PermissionsStartOnly=true
User=odoo16
Group=odoo16
ExecStart=/opt/odoo16/odoo16-venv/bin/python3 /opt/odoo16/odoo/odoo-bin -c /etc/odoo16.conf
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now odoo16
sudo systemctl status odoo16

echo " odoo16 install complete"
