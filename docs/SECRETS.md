# Secrets Wiring

Principle: secrets never land in git. One secret per file, decrypted at runtime.

Infrastructure (OpenTofu):
- AWS credentials via environment variable (required for `infra/opentofu/aws`).
- Do NOT commit `*.tfvars` with secrets.

Image pipeline (CI):
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_REGION` / `S3_BUCKET` (required).
- `BOTCTL_AGE_KEY` (required; used to build the bootstrap bundle uploaded to S3).

Local storage:
- Keep AWS keys encrypted in `../nix/nix-secrets` for local runs if needed.
- CI pulls credentials from GitHub Actions secrets (never from host files).

Runtime (BOTCTL):
- Discord bot token (required, per instance).
- GitHub token (required): GitHub App installation token (preferred) or a read-only PAT.
- Anthropic API key (required for Claude models).
- OpenAI API key (required for OpenAI models).

Explicit token files (standard):
- `services.botctl.discordTokenFile`
- `services.botctl.anthropicApiKeyFile`
- `services.botctl.openaiApiKeyFile`
- `services.botctl.githubPatFile` (PAT path, if not using GitHub App; exports `GITHUB_TOKEN` + `GH_TOKEN`)

GitHub App (preferred):
- Private key PEM decrypted to `/run/agenix/botctl-github-app.pem`.
- App ID + Installation ID in `services.botctl.githubApp.*`.
- Timer mints short-lived tokens into `/run/bot/github-app.env` with `GITHUB_TOKEN` + `GH_TOKEN`.

Agenix (local secrets repo):
- Store encrypted files in `../nix/nix-secrets` (relative to this repo).
- Sync encrypted secrets to the host at `/var/lib/bot/nix-secrets`.
- Decrypt on host with agenix; point NixOS options at `/run/agenix/*`.
- Image builds do **not** bake the agenix identity; the age key is injected at runtime via the bootstrap bundle.
- Required files (minimum): `botctl-github-app.pem.age`, `botctl-discord-token.age`, `botctl-anthropic-api-key.age`.
- Also required for OpenAI: `botctl-openai-api-key-peter-2.age`.
- CI image pipeline (stored locally, not on hosts): `botctl-image-uploader-access-key-id.age`, `botctl-image-uploader-secret-access-key.age`, `botctl-image-bucket-name.age`, `botctl-image-bucket-region.age`.

Bootstrap bundle (runtime injection):
- CI uploads `secrets.tar.zst` + `repo-seeds.tar.zst` to `s3://${S3_BUCKET}/bootstrap/<instance>/`.
- `secrets.tar.zst` contains:
  - `botctl.agekey`
  - `secrets/` directory with `*.age` files.
- The host downloads + installs these on boot (`botctl-bootstrap.service`).

Example NixOS wiring (agenix):
```
{ inputs, ... }:
{
  imports = [ inputs.agenix.nixosModules.default ];

  age.secrets."botctl-github-app.pem".file =
    "/var/lib/bot/nix-secrets/botctl-github-app.pem.age";
  age.secrets."botctl-anthropic-api-key".file =
    "/var/lib/bot/nix-secrets/botctl-anthropic-api-key.age";
  age.secrets."botctl-openai-api-key-peter-2".file =
    "/var/lib/bot/nix-secrets/botctl-openai-api-key-peter-2.age";
  age.secrets."botctl-discord-token".file =
    "/var/lib/bot/nix-secrets/botctl-discord-token.age";

  services.botctl.githubApp.privateKeyFile =
    "/run/agenix/botctl-github-app.pem";
  services.botctl.anthropicApiKeyFile =
    "/run/agenix/botctl-anthropic-api-key";
  services.botctl.openaiApiKeyFile =
    "/run/agenix/botctl-openai-api-key-peter-2";
  services.botctl.discordTokenFile =
    "/run/agenix/botctl-discord-token";
}
```
