terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.34"
    }
  }
  required_version = ">= 1.6.0"
}

provider "digitalocean" {
  token = var.do_token
}

# ---------------------------------------------------------------------------
# Droplet
# ---------------------------------------------------------------------------

resource "digitalocean_droplet" "hanzobot" {
  name     = var.droplet_name
  region   = var.region
  size     = var.droplet_size
  image    = var.droplet_image
  ssh_keys = var.ssh_key_ids
  tags     = ["hanzobot", "production"]

  user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail

    # Install Docker
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker
    systemctl start docker

    # Install Docker Compose plugin
    apt-get install -y docker-compose-plugin

    # Install doctl CLI
    cd /tmp
    curl -sL https://github.com/digitalocean/doctl/releases/latest/download/doctl-$(curl -s https://api.github.com/repos/digitalocean/doctl/releases/latest | grep tag_name | cut -d '"' -f4 | sed 's/v//')-linux-amd64.tar.gz | tar xz
    mv doctl /usr/local/bin/

    # Create hanzobot user
    useradd -m -s /bin/bash -G docker hanzobot

    # Mount block storage
    mkdir -p /mnt/hanzobot-data
    echo "/dev/disk/by-id/scsi-0DO_Volume_${var.volume_name} /mnt/hanzobot-data ext4 defaults,nofail,discard 0 0" >> /etc/fstab
    mount -a || true

    chown hanzobot:hanzobot /mnt/hanzobot-data
  EOF
}

# ---------------------------------------------------------------------------
# Block storage
# ---------------------------------------------------------------------------

resource "digitalocean_volume" "hanzobot_data" {
  name                    = var.volume_name
  region                  = var.region
  size                    = var.volume_size_gb
  initial_filesystem_type = "ext4"
  description             = "Persistent storage for HanzoBot state"
  tags                    = ["hanzobot"]
}

resource "digitalocean_volume_attachment" "hanzobot_data" {
  droplet_id = digitalocean_droplet.hanzobot.id
  volume_id  = digitalocean_volume.hanzobot_data.id
}

# ---------------------------------------------------------------------------
# Firewall
# ---------------------------------------------------------------------------

resource "digitalocean_firewall" "hanzobot" {
  name        = "hanzobot-fw"
  droplet_ids = [digitalocean_droplet.hanzobot.id]

  # SSH
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.ssh_allowed_cidrs
  }

  # HTTPS
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # HTTP (for cert challenges)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Tailscale UDP
  inbound_rule {
    protocol         = "udp"
    port_range       = "41641"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # All outbound
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# ---------------------------------------------------------------------------
# Spaces bucket (S3-compatible backup storage)
# ---------------------------------------------------------------------------

resource "digitalocean_spaces_bucket" "hanzobot_backups" {
  count  = var.enable_backups ? 1 : 0
  name   = var.spaces_bucket_name
  region = var.spaces_region
  acl    = "private"

  lifecycle_rule {
    enabled = true
    expiration {
      days = 30
    }
  }
}

# ---------------------------------------------------------------------------
# DNS
# ---------------------------------------------------------------------------

resource "digitalocean_record" "hanzobot" {
  count  = var.domain != "" ? 1 : 0
  domain = var.domain
  type   = "A"
  name   = var.subdomain
  value  = digitalocean_droplet.hanzobot.ipv4_address
  ttl    = 300
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "droplet_ip" {
  value       = digitalocean_droplet.hanzobot.ipv4_address
  description = "Public IPv4 of the HanzoBot droplet"
}

output "droplet_id" {
  value = digitalocean_droplet.hanzobot.id
}

output "volume_id" {
  value = digitalocean_volume.hanzobot_data.id
}
