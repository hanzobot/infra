# CLAWDINATORS

CLAWDINATORS are maintainer‑grade coding agents. This repo defines how to spawn them
declaratively (OpenTofu + NixOS). Humans are not in the loop.

Principles:
- Declarative‑first. A CLAWDINATOR can bootstrap another CLAWDINATOR with a single command.
- No manual host edits. The repo + agenix secrets are the source of truth.
- Latest upstream nix‑clawdbot by default; breaking changes are acceptable.

Stack:
- Hetzner hosts provisioned with OpenTofu.
- NixOS modules configure Clawdbot and CLAWDINATOR runtime.
- Shared hive‑mind memory stored on a mounted host volume.

Shared memory (hive mind):
- All instances share the same memory files (no per‑instance prefixes for canonical files).
- Daily notes can be per‑instance: `YYYY-MM-DD_INSTANCE.md`.
- Canonical files are single shared sources of truth.

Example layout:
```
~/clawd/
├── memory/
│ ├── project.md # Project goals + non-negotiables
│ ├── architecture.md # Architecture decisions + invariants
│ ├── discord.md # Discord-specific stuff
│ ├── whatsapp.md # WhatsApp-specific stuff
│ └── 2026-01-06.md # Daily notes
```

Secrets (required):
- GitHub App private key (for short‑lived installation tokens).
- Discord bot token (per instance).
- Anthropic API key (Claude models).
- Hetzner API token (OpenTofu).

Secrets are stored in `../nix/nix-secrets` using agenix and decrypted to `/run/agenix/*`
on hosts. See `docs/SECRETS.md`.

Deploy (automation‑first):
- `infra/opentofu` provisions Hetzner hosts.
- Host config lives in `nix/hosts/*` and is exposed in `flake.nix`.
- Install with `nixos-anywhere` and point it at the flake host.
- Ensure `/var/lib/clawd/repo` contains this repo (needed for self‑update).
- Configure Discord guild/channel allowlist and GitHub App installation ID.

Docs:
- `docs/PHILOSOPHY.md`
- `docs/ARCHITECTURE.md`
- `docs/SHARED_MEMORY.md`
- `docs/POC.md`
- `docs/SECRETS.md`
- `docs/SKILLS_AUDIT.md`

Repo layout:
- `infra/opentofu` — Hetzner provisioning
- `nix/modules/clawdinator.nix` — NixOS module
- `nix/hosts/` — host configs
- `nix/examples/` — example host + flake wiring
- `memory/` — template memory files

Operating mode:
- No manual setup. Machines are created by automation (other CLAWDINATORS).
- Everything is in repo + agenix. No ad‑hoc changes on hosts.
