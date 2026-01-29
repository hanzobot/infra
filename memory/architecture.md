# Architecture Memory

Canonical architecture decisions and invariants for BOTCTL.

- Infra: OpenTofu + AWS AMI pipeline for host provisioning.
- Config: NixOS modules/flake, tracking latest nix-bot.
- Runtime: Bot gateway + BOTCTL service.
- Memory: shared filesystem under /var/lib/bot/memory.

Update this when architecture decisions change.
