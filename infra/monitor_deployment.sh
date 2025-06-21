#!/bin/bash

# Monitor Supabase Deployment Script
echo "🔍 Monitoring Supabase Deployment Status"
echo "========================================"
echo ""

SERVER_IP="97.107.141.101"
SSH_KEY="~/.ssh/supabase_key"

echo "🌐 Server IP: $SERVER_IP"
echo "🔑 SSH Key: $SSH_KEY"
echo ""

echo "📋 Testing SSH Connection..."
if ssh -i ~/.ssh/supabase_key -o ConnectTimeout=5 -o StrictHostKeyChecking=no supabase@$SERVER_IP "echo 'Connected'" 2>/dev/null; then
    echo "✅ SSH connection successful!"
    echo ""
    
    echo "🔍 Checking cloud-init status..."
    ssh -i ~/.ssh/supabase_key supabase@$SERVER_IP "sudo cloud-init status" 2>/dev/null || echo "❓ Cloud-init status not available"
    echo ""
    
    echo "🐳 Checking Docker installation..."
    if ssh -i ~/.ssh/supabase_key supabase@$SERVER_IP "which docker" 2>/dev/null; then
        echo "✅ Docker is installed"
        
        echo "📦 Checking Docker containers..."
        ssh -i ~/.ssh/supabase_key supabase@$SERVER_IP "cd /home/supabase && docker-compose ps" 2>/dev/null || echo "❓ Docker Compose not ready yet"
    else
        echo "⏳ Docker not installed yet - cloud-init still running"
    fi
    echo ""
    
    echo "🌐 Testing Supabase endpoints..."
    echo "Studio (Port 3000): $(curl -s -o /dev/null -w "%{http_code}" http://$SERVER_IP:3000 --connect-timeout 5 || echo "Not responding")"
    echo "API (Port 8000): $(curl -s -o /dev/null -w "%{http_code}" http://$SERVER_IP:8000 --connect-timeout 5 || echo "Not responding")"
    echo ""
    
else
    echo "❌ SSH connection failed - server might still be booting"
fi

echo "📝 To monitor cloud-init progress in real-time:"
echo "ssh -i ~/.ssh/supabase_key supabase@$SERVER_IP 'sudo journalctl -u cloud-final -f'"
echo ""
echo "🌐 Access URLs (try in 5-10 minutes):"
echo "Studio Dashboard: http://$SERVER_IP:3000"
echo "API Endpoint: http://$SERVER_IP:8000"
