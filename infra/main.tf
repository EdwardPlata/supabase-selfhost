# main.tf
terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.13.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

provider "linode" {
  token = var.linode_api_token
}

# Generate secure secrets
resource "random_password" "postgres" {
  length  = 24
  special = false
}

resource "random_password" "jwt_secret" {
  length  = 32
  special = false
}

resource "random_password" "dashboard" {
  length  = 16
  special = false
}

# Create firewall for Supabase
resource "linode_firewall" "supabase_firewall" {
  label = "supabase-firewall"
  tags  = ["supabase"]

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  inbound {
    label    = "ssh"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "http-https"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80,443"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "supabase-studio"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "3000"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "supabase-api"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "8000"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "postgres"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "5432"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  outbound {
    label    = "all-outbound"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "1-65535"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  outbound {
    label    = "all-outbound-udp"
    action   = "ACCEPT"
    protocol = "UDP"
    ports    = "1-65535"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }
}

# Create Linode instance
resource "linode_instance" "supabase" {
  label           = "supabase-server"
  region          = "us-east"
  type            = "g6-standard-2"  # 4GB RAM, 2 CPU - better for Supabase
  image           = "linode/ubuntu22.04"
  authorized_keys = [var.ssh_public_key]
  root_pass       = random_password.dashboard.result
  private_ip      = true
  firewall_id     = linode_firewall.supabase_firewall.id

  # Instance metadata for easier management
  group = "supabase"
  tags  = ["database", "backend", "supabase"]

  # Cloud-init script for initial configuration
  metadata {
    user_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
      postgres_password = random_password.postgres.result
      jwt_secret        = random_password.jwt_secret.result
      dashboard_user    = "admin"
      dashboard_pass    = random_password.dashboard.result
      ssh_public_key    = var.ssh_public_key
    }))
  }
}

# DNS configuration (optional)
resource "linode_domain_record" "supabase" {
  count      = var.domain_name != "" ? 1 : 0
  domain_id  = var.domain_id
  name       = var.domain_name
  record_type = "A"
  target     = linode_instance.supabase.ip_address
  ttl_sec    = 300
}

# Output important information
output "supabase_urls" {
  value = {
    studio       = "http://${linode_instance.supabase.ip_address}:3000"
    api          = "http://${linode_instance.supabase.ip_address}:8000"
    postgres     = "postgresql://postgres:${random_password.postgres.result}@${linode_instance.supabase.ip_address}:5432/postgres"
    ssh_access   = "ssh supabase@${linode_instance.supabase.ip_address}"
  }
  sensitive = true
}

output "server_info" {
  value = {
    ip_address     = linode_instance.supabase.ip_address
    private_ip     = linode_instance.supabase.private_ip_address
    instance_id    = linode_instance.supabase.id
    firewall_id    = linode_firewall.supabase_firewall.id
    region         = linode_instance.supabase.region
    type           = linode_instance.supabase.type
  }
}

output "credentials" {
  value = {
    dashboard_user = "admin"
    dashboard_pass = random_password.dashboard.result
    postgres_pass  = random_password.postgres.result
    jwt_secret     = random_password.jwt_secret.result
    root_pass      = random_password.dashboard.result
  }
  sensitive = true
}