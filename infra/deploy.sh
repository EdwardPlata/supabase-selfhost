#!/bin/bash

# Supabase Self-Host Deployment Script
# This script deploys Supabase to Linode using Terraform

set -e

echo "🚀 Supabase Self-Host Deployment Script"
echo "======================================="

# Check if required files exist
if [ ! -f "variables.tfvars" ]; then
    echo "❌ Error: variables.tfvars file not found!"
    echo "Please copy variables.tfvars.example to variables.tfvars and update the values."
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Error: Terraform is not installed!"
    echo "Please install Terraform: https://www.terraform.io/downloads.html"
    exit 1
fi

echo "📋 Checking configuration..."

# Validate Terraform configuration
terraform init
terraform validate

if [ $? -eq 0 ]; then
    echo "✅ Configuration is valid!"
else
    echo "❌ Configuration validation failed!"
    exit 1
fi

echo ""
echo "📋 Terraform Plan"
echo "=================="
terraform plan -var-file="variables.tfvars"

echo ""
read -p "🤔 Do you want to proceed with the deployment? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Deploying Supabase..."
    terraform apply -var-file="variables.tfvars" -auto-approve
    
    echo ""
    echo "🎉 Deployment completed!"
    echo ""
    echo "📋 Next Steps:"
    echo "=============="
    echo "1. Wait 5-10 minutes for cloud-init to complete"
    echo "2. Access Supabase Studio at the URL shown above"
    echo "3. Use the API endpoint for your applications"
    echo ""
    echo "🔍 To check deployment status:"
    echo "ssh supabase@$(terraform output -raw server_info | jq -r '.ip_address') 'sudo journalctl -u cloud-final -f'"
    echo ""
    echo "🔐 To view sensitive outputs:"
    echo "terraform output credentials"
else
    echo "❌ Deployment cancelled."
    exit 1
fi
