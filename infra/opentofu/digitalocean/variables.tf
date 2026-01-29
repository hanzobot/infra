variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc3"
}

variable "droplet_name" {
  description = "Name for the HanzoBot droplet"
  type        = string
  default     = "hanzobot-prod"
}

variable "droplet_size" {
  description = "Droplet size slug"
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "droplet_image" {
  description = "Droplet base image"
  type        = string
  default     = "ubuntu-24-04-x64"
}

variable "ssh_key_ids" {
  description = "List of SSH key IDs to add to the droplet"
  type        = list(string)
  default     = []
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH into the droplet"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "volume_name" {
  description = "Name for the block storage volume"
  type        = string
  default     = "hanzobot-data"
}

variable "volume_size_gb" {
  description = "Size of the block storage volume in GB"
  type        = number
  default     = 20
}

variable "enable_backups" {
  description = "Enable Spaces bucket for state backups"
  type        = bool
  default     = true
}

variable "spaces_bucket_name" {
  description = "Name for the Spaces backup bucket"
  type        = string
  default     = "hanzobot-backups"
}

variable "spaces_region" {
  description = "Region for Spaces bucket"
  type        = string
  default     = "nyc3"
}

variable "domain" {
  description = "Domain for DNS record (e.g. hanzo.ai). Empty to skip."
  type        = string
  default     = ""
}

variable "subdomain" {
  description = "Subdomain for DNS record (e.g. bot)"
  type        = string
  default     = "bot"
}
