# Self-Hosted Supabase on Linode

This repository contains Terraform configuration to deploy a self-hosted Supabase instance on Linode. The setup includes all core Supabase services: PostgreSQL database, PostgREST API, GoTrue authentication, Realtime subscriptions, Storage, and Studio dashboard.

## 🚀 Quick Start

### Prerequisites

1. **Linode Account**: Sign up at [linode.com](https://linode.com)
2. **Linode API Token**: Generate at [cloud.linode.com/profile/tokens](https://cloud.linode.com/profile/tokens)
3. **Terraform**: Install from [terraform.io](https://terraform.io/downloads)
4. **SSH Key Pair**: Generate with `ssh-keygen -t rsa -b 4096`

### Deployment

1. **Clone and Configure**:
   ```bash
   git clone <your-repo>
   cd supabase-selfhost/infra
   cp variables.tfvars.example variables.tfvars
   ```

2. **Edit Configuration**:
   ```bash
   nano variables.tfvars
   ```
   Update with your Linode API token and SSH public key.

3. **Deploy**:
   ```bash
   ./deploy.sh
   ```
   Or manually:
   ```bash
   terraform init
   terraform plan -var-file="variables.tfvars"
   terraform apply -var-file="variables.tfvars"
   ```

4. **Access Your Instance**:
   - **Supabase Studio**: `http://your-ip:3000`
   - **API Endpoint**: `http://your-ip:8000`
   - **SSH Access**: `ssh supabase@your-ip`

## 📋 What's Included

### Infrastructure
- **Linode Instance**: g6-standard-2 (4GB RAM, 2 vCPU)
- **Firewall Rules**: Properly configured for all Supabase services
- **Auto-scaling**: Ready for production workloads
- **Security**: SSH key authentication, UFW firewall

### Supabase Services
- **PostgreSQL 15**: Primary database with optimized configuration
- **PostgREST**: Auto-generated REST API
- **GoTrue**: User authentication and authorization
- **Realtime**: WebSocket connections for live data
- **Storage**: File upload and management
- **Studio**: Web-based dashboard and SQL editor
- **Kong**: API gateway and routing

## 🔧 Configuration

### Instance Sizing
Current configuration uses `g6-standard-2` (4GB RAM, 2 vCPU). For different workloads:

- **Development**: `g6-standard-1` (2GB RAM, 1 vCPU) - $12/month
- **Production**: `g6-standard-4` (8GB RAM, 4 vCPU) - $48/month
- **High-performance**: `g6-standard-6` (16GB RAM, 6 vCPU) - $96/month

### Custom Domain (Optional)
To use a custom domain:
1. Add your domain to Linode DNS Manager
2. Update `variables.tfvars` with domain information
3. Configure SSL with Let's Encrypt (post-deployment)

## 📞 Support

For issues with this deployment:
- Open a GitHub issue  
- Check Terraform documentation
- Consult Linode support for infrastructure issues
- Review Supabase documentation for application issues