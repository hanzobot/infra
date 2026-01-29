{ secrets, ... }:
{
  age.secrets."botctl-github-app.pem".file =
    "/var/lib/bot/nix-secrets/botctl-github-app.pem.age";
  age.secrets."botctl-anthropic-api-key".file =
    "/var/lib/bot/nix-secrets/botctl-anthropic-api-key.age";
  age.secrets."botctl-openai-api-key-peter-2".file =
    "/var/lib/bot/nix-secrets/botctl-openai-api-key-peter-2.age";
  age.secrets."botctl-discord-token".file =
    "/var/lib/bot/nix-secrets/botctl-discord-token.age";

  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 18789 ];

  services.botctl = {
    enable = true;
    instanceName = "BOTCTL-1";
    memoryDir = "/memory";
    memoryEfs = {
      enable = true;
      fileSystemId = "fs-0e7920726c2965a88";
      region = "eu-central-1";
      mountPoint = "/memory";
    };

    # Raw Bot config JSON (schema is upstream). Extend as needed.
    config = {
      gateway.mode = "server";
      agents.defaults.workspace = "/var/lib/bot/workspace";
      messages.queue.byProvider = {
        discord = "queue";
        telegram = "interrupt";
        whatsapp = "interrupt";
      };
      agents.list = [
        {
          id = "main";
          default = true;
          identity.name = "BOTCTL-1";
        }
      ];
      skills.allowBundled = [ "github" "bothub" ];
      discord = {
        enabled = true;
        dm.enabled = false;
        guilds = {
          "<GUILD_ID>" = {
            requireMention = true;
            channels = {
              "<CHANNEL_NAME>" = { allow = true; requireMention = true; };
            };
          };
        };
      };
    };

    anthropicApiKeyFile = "/run/agenix/botctl-anthropic-api-key";
    openaiApiKeyFile = "/run/agenix/botctl-openai-api-key-peter-2";
    discordTokenFile = "/run/agenix/botctl-discord-token";

    githubApp = {
      enable = true;
      appId = "123456";
      installationId = "12345678";
      privateKeyFile = "/run/agenix/botctl-github-app.pem";
      schedule = "hourly";
    };

    selfUpdate.enable = true;
    selfUpdate.flakePath = "/var/lib/bot/repo";
    selfUpdate.flakeHost = "botctl-1";
  };
}
