provider "hcloud" {
  token = var.hcloud_token
}

locals {
  instances = toset([for i in range(var.instance_count) : tostring(i + 1)])
  ssh_public_key = (
    var.ssh_public_key != null
    ? var.ssh_public_key
    : (var.ssh_public_key_path != null ? file(var.ssh_public_key_path) : null)
  )
}

data "hcloud_ssh_key" "keys" {
  for_each = toset(var.ssh_key_names)
  name     = each.value
}

resource "hcloud_ssh_key" "generated" {
  count      = local.ssh_public_key != null ? 1 : 0
  name       = var.ssh_key_name
  public_key = local.ssh_public_key
}

resource "hcloud_server" "clawdinator" {
  for_each    = local.instances
  name        = format("%s-%s", var.name_prefix, each.value)
  server_type = var.server_type
  image       = var.image
  location    = var.location
  ssh_keys = concat(
    [for _, k in data.hcloud_ssh_key.keys : k.name],
    local.ssh_public_key != null ? [hcloud_ssh_key.generated[0].name] : []
  )
}

resource "hcloud_volume" "clawd" {
  for_each = var.volume_size_gb > 0 ? local.instances : []

  name     = format("%s-%s", var.name_prefix, each.value)
  size     = var.volume_size_gb
  location = var.location
}

resource "hcloud_volume_attachment" "clawd" {
  for_each = var.volume_size_gb > 0 ? local.instances : []

  volume_id = hcloud_volume.clawd[each.value].id
  server_id = hcloud_server.clawdinator[each.value].id
  # NixOS handles formatting/mounting; keep Hetzner automount off.
  automount = false
}
