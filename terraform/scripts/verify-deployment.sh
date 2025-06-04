#!/usr/bin/env bash
# terraform/scripts/verify-deployment.sh - AWS version
set -e

echo "Verifying deployment..."
sleep 5

# Get IP from terraform output
get_ip() {
  local ip=$(terraform output -raw vm_ip 2>/dev/null || echo "")
  
  if [ -n "$ip" ] && [ "$ip" != "null" ]; then
    echo "$ip"
    return 0
  fi
  
  echo ""
  return 1
}

IP=$(get_ip)

if [ -n "$IP" ]; then
  echo "Testing service at http://$IP:5000/ping"
  if curl -f -s http://"$IP":5000/ping; then
    echo ""
    echo "✅ Basic health check successful!"
    
    # Test the config endpoint
    echo ""
    echo "Testing configuration endpoint..."
    echo "curl http://$IP:5000/pico_iot_config.json | head -10:"
    echo "---"
    curl -f -s http://"$IP":5000/pico_iot_config.json | head -10
    echo "---"
    echo ""
  else
    echo ""
    echo "❌ Health check failed - service may still be starting"
    echo "ℹ️  You can manually test: curl http://$IP:5000/ping"
    echo "ℹ️  Server IP: $IP"
    exit 1
  fi
else
  echo "❌ Could not determine valid IP for verification"
  exit 1
fi
