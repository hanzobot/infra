# Nix/NixOS

This directory holds Nix modules/flakes to configure BOTCTL hosts.

References (local repos on the same machine):
- `../nix/ai-stack`
- `../nix/nixos-config`
- `../nix/nix-bot`

Responsibilities:
- Install and configure bot runtime
- Set up systemd services
- Mount /var/lib/bot (shared memory)
- Inject secrets (Discord token, Anthropic key, GitHub token)

Module:
- `nix/modules/botctl.nix` provides `services.botctl`
- Example host config: `nix/examples/botctl-host.nix`
- Example flake wiring: `nix/examples/flake.nix`

Hosts:
- `nix/hosts/botctl-1.nix` is the first host config (templated; no machine-specific secrets)

Secrets:
- Explicit token files only: `discordTokenFile`, `anthropicApiKeyFile`, and either `githubPatFile` or `githubApp.*`.

Updates:
- Tracks `github:bot/nix-bot` (latest upstream)
- Self-update timer available via `services.botctl.selfUpdate.*`
