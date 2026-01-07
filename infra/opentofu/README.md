# OpenTofu (Hetzner)

This directory provisions CLAWDINATOR hosts using OpenTofu.

Prereqs:
- OpenTofu >= 1.6
- Hetzner API token
- SSH keys registered in Hetzner (or provide a local public key to upload)

Secrets wiring:
- Prefer env var: `HCLOUD_TOKEN`
- Do NOT commit tokens or tfvars

Example usage:
- export HCLOUD_TOKEN=...
- tofu init
- tofu plan -var='ssh_key_names=["my-laptop"]' -var='instance_count=1'
- tofu apply -var='ssh_key_names=["my-laptop"]' -var='instance_count=1'

SSH keys:
- Use an existing Hetzner key: `ssh_key_names = ["my-hetzner-key"]`
- Or upload a local key: `ssh_public_key_path = "~/.ssh/id_ed25519.pub"`
- Optional name for uploaded key: `ssh_key_name = "clawdinator-default"`

Example vars file:
- `infra/opentofu/example.tfvars` (safe template; contains no secrets)

Notes:
- POC uses one volume per host for /var/lib/clawd.
- Volumes are attached without automount; NixOS formats/mounts them.
- A single Hetzner volume cannot be attached to multiple hosts. For multi-host hive-mind memory, add a shared FS (NFS/Ceph) or object-sync layer later.
