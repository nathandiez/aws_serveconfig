#!/bin/bash
# terraform/vm-module/user_data.sh - Basic setup for EC2 instance

# Update the system
apt-get update

# Install basic packages
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    python3-pip \
    avahi-daemon

# Set timezone
timedatectl set-timezone America/New_York

# Configure Avahi for .local hostname resolution
mkdir -p /etc/avahi/avahi-daemon.conf.d
cat > /etc/avahi/avahi-daemon.conf.d/10-hostname.conf << 'EOF2'
[server]
host-name=nedv1-serveconfig

[publish]
publish-hinfo=yes
publish-workstation=yes
EOF2

# Disable IPv6 in Avahi
sed -i 's/^#use-ipv6=yes/use-ipv6=no/' /etc/avahi/avahi-daemon.conf

# Restart avahi
systemctl restart avahi-daemon
systemctl enable avahi-daemon

# Signal that user data script is complete
touch /var/lib/cloud/instance/user-data-finished
