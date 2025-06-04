#!/usr/bin/env bash
# terraform/scripts/wait-for-ssh.sh - AWS version
set -e

echo "Waiting for SSH to become available..."
max_attempts=30
attempt=0

# Function to get IP from AWS
get_ip() {
  local ip=$(terraform output -raw vm_ip 2>/dev/null || echo "")
  
  if [ -n "$ip" ] && [ "$ip" != "null" ]; then
    echo "$ip"
    return 0
  fi
  
  echo ""
  return 1
}

# Get IP address with retries
for i in {1..3}; do
  IP=$(get_ip)
  if [ -n "$IP" ]; then
    break
  fi
  echo "IP detection attempt $i failed, waiting 10 seconds..."
  sleep 10
done

if [ -z "$IP" ]; then
  echo "Error: Could not retrieve a valid IP address after multiple attempts"
  exit 1
fi

echo "Using IP: $IP"

# Update Ansible inventory with correct IP
mkdir -p ../ansible/inventory
echo "Updating Ansible inventory with IP: $IP"
cat > ../ansible/inventory/hosts << EOF2
[serve_config_servers]
nedv1-serveconfig ansible_host=$IP

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_user=ubuntu
EOF2

# Now wait for SSH
while [ $attempt -lt $max_attempts ]; do
  if ssh -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=5 ubuntu@"$IP" echo ready 2>/dev/null; then
    echo "SSH is available!"
    break
  fi
  attempt=$((attempt + 1))
  echo "Attempt $attempt/$max_attempts - Still waiting for SSH..."
  sleep 10
done

if [ $attempt -eq $max_attempts ]; then
  echo "Timed out waiting for SSH"
  exit 1
fi
