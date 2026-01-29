# Architecture (Draft)

Goal: declaratively spawn BOTCTL instances on AWS using OpenTofu + NixOS.

Operating mode:
- declarative-first, no manual setup
- machines are created by automation (another BOTCTL)

Core pieces:
- AWS AMIs are built from a prebuilt NixOS image (nixos-generators + import-image).
- AWS EC2 instances are launched from those AMIs via OpenTofu.
- NixOS modules configure bot + BOTCTL runtime on each host.
- Shared memory is mounted at a consistent path on all hosts.

Runtime layout (planned):
- /var/lib/bot/memory (shared hive-mind memory)
- /var/lib/bot/workspace (agent workspace)
- /var/lib/bot/logs (gateway logs)
- /var/lib/bot/repo (this repo for self-update)

Storage:
- POC uses one host volume per instance (e.g., EBS), mounted at /var/lib/bot.
- In multi-host mode, add a shared filesystem or object-sync layer and keep canonical memory files authoritative.

Instance naming:
- BOTCTL-{1..n}
- Daily notes can be per-instance (YYYY-MM-DD_INSTANCE.md)
- Canonical files are shared (goals, architecture, ops, etc.)

Upstream freshness:
- Nix flake input tracks `github:bot/nix-bot` (latest upstream).
- Update with `nix flake update` and rebuild hosts.
- Optional self-update timer is available in the Nix module.
- Self-update expects this repo to be present on the host (default: /var/lib/bot/repo).
- Updates will refresh flake.lock; review before applying in prod.
- GitHub App tokens are refreshed via a systemd timer when enabled.
