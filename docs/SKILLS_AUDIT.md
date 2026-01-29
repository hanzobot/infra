# Skills Audit (Bundled)

Goal: keep the headless BOTCTL surface minimal and relevant. Bundled skills include many desktop- or device-specific integrations that don’t make sense on a server.

Not a fit for headless servers (examples):
- macOS or local-app skills (apple-notes, apple-reminders, things-mac, bear-notes, obsidian).
- device/IoT skills (openhue, sonoscli, spotify-player).
- camera/GUI skills (camsnap, peekaboo, video-frames).
- personal chat clients or local-only tooling (imsg, wacli).

Recommendation:
- Use a bundled allowlist so only explicitly chosen skills load.
- Start minimal and add when needed.

Suggested allowlist for BOTCTL:
- `github` (issues/PRs via gh)
- `skills` (install/update skills on demand)
- `coding-agent` (optional; only if Codex/Claude binaries are installed on the host)
- `brave-search` (optional; requires API key)

Implementation (in Nix):
```
services.botctl.config.skills.allowBundled = [ "github" "skills" ];
```
