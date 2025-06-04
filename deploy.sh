#!/usr/bin/env bash
# deploy.sh - AWS version
set -e

# Configuration
TARGET_HOSTNAME="nedv1-serveconfig"

# Check for --local-exec flag
USE_LOCAL_EXEC=false
if [ "$1" = "--local-exec" ]; then
   USE_LOCAL_EXEC=true
   echo "Starting deployment of $TARGET_HOSTNAME with integrated local-exec provisioners..."
else
   echo "Starting deployment of $TARGET_HOSTNAME with manual deployment..."
fi

# Source AWS environment variables
source ./set-aws-env.sh

# Change to terraform directory
cd "$(dirname "$0")/terraform"

# Initialize and apply Terraform
echo "Initializing Terraform..."
terraform init

echo "Creating/updating infrastructure..."
if [ "$USE_LOCAL_EXEC" = true ]; then
   terraform apply -var="enable_local-exec=true" -auto-approve
   echo ""
   echo "✅ DEPLOYMENT COMPLETE with integrated provisioners!"
   echo "✅ Check the terraform output above for service details"
else
   terraform apply -var="enable_local-exec=false" -auto-approve
   echo ""  
   echo "✅ Infrastructure created! Run Ansible manually to complete setup."
fi

cd ..
echo "✅ Deployment finished!"
