# variables.tf
variable "linode_api_token" {
  description = "Linode API token"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
}

variable "domain_name" {
  description = "Domain name for DNS record (optional)"
  type        = string
  default     = ""
}

variable "domain_id" {
  description = "Linode domain ID for DNS record (optional)"
  type        = string
  default     = ""
}