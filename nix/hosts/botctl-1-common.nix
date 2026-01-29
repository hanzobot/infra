{ lib, config, ... }:
let
  secretsPath = config.botctl.secretsPath;
  repoSeedsFile = ../../botctl/repos.tsv;
  repoSeedLines =
    lib.filter
      (line: line != "" && !lib.hasPrefix "#" line)
      (map lib.strings.trim (lib.splitString "\n" (lib.fileContents repoSeedsFile)));
  parseRepoSeed = line:
    let
      parts = lib.splitString "\t" line;
      name = lib.elemAt parts 0;
      url = lib.elemAt parts 1;
      branch =
        if (lib.length parts) > 2 && (lib.elemAt parts 2) != ""
        then lib.elemAt parts 2
        else null;
    in
    { inherit name url branch; };
  repoSeeds = map parseRepoSeed repoSeedLines;
in
{
  options.botctl.secretsPath = lib.mkOption {
    type = lib.types.str;
    description = "Path to encrypted age secrets for BOTCTL.";
  };

  config = {
    botctl.secretsPath = "/var/lib/bot/nix-secrets";

    age.identityPaths = [ "/etc/agenix/keys/botctl.agekey" ];
    age.secrets."botctl-github-app.pem" = {
      file = "${secretsPath}/botctl-github-app.pem.age";
      owner = "botctl";
      group = "botctl";
    };
    age.secrets."botctl-anthropic-api-key" = {
      file = "${secretsPath}/botctl-anthropic-api-key.age";
      owner = "botctl";
      group = "botctl";
    };
    age.secrets."botctl-openai-api-key-peter-2" = {
      file = "${secretsPath}/botctl-openai-api-key-peter-2.age";
      owner = "botctl";
      group = "botctl";
    };
    age.secrets."botctl-discord-token" = {
      file = "${secretsPath}/botctl-discord-token.age";
      owner = "botctl";
      group = "botctl";
    };

    services.botctl = {
      enable = true;
      instanceName = "BOTCTL-1";
      memoryDir = "/memory";
      repoSeedSnapshotDir = "/var/lib/bot/repo-seeds";
      bootstrap = {
        enable = true;
        s3Bucket = "botctl-images-eu1-20260107165216";
        s3Prefix = "bootstrap/botctl-1";
        region = "eu-central-1";
        secretsDir = "/var/lib/bot/nix-secrets";
        repoSeedsDir = "/var/lib/bot/repo-seeds";
        ageKeyPath = "/etc/agenix/keys/botctl.agekey";
      };
      memoryEfs = {
        enable = true;
        fileSystemId = "fs-0e7920726c2965a88";
        region = "eu-central-1";
        mountPoint = "/memory";
      };
      repoSeeds = repoSeeds;

      config = {
        gateway.mode = "local";
        agents.defaults = {
          workspace = "/var/lib/bot/workspace";
          maxConcurrent = 4;
          skipBootstrap = true;
          models = {
            "anthropic/claude-opus-4-5" = { alias = "Opus"; };
            "openai/gpt-5-codex" = { alias = "Codex"; };
          };
          model = {
            primary = "anthropic/claude-opus-4-5";
            fallbacks = [ "openai/gpt-5-codex" ];
          };
        };
        agents.list = [
          {
            id = "main";
            default = true;
            identity.name = "BOTCTL-1";
          }
        ];
        logging = {
          level = "info";
          file = "/var/lib/bot/logs/bot.log";
        };
        session.sendPolicy = {
          default = "allow";
          rules = [
            {
              action = "deny";
              match.keyPrefix = "agent:main:discord:channel:1458138963067011176";
            }
            {
              action = "deny";
              match.keyPrefix = "agent:main:discord:channel:1458141495701012561";
            }
          ];
        };
        messages.queue = {
          mode = "interrupt";
          byProvider = {
            discord = "interrupt";
            telegram = "interrupt";
            whatsapp = "interrupt";
            webchat = "queue";
          };
        };
        skills.allowBundled = [ "github" "bothub" ];
        cron = {
          enabled = true;
          store = "/var/lib/bot/cron-jobs.json";
        };
        discord = {
          enabled = true;
          dm.enabled = false;
          guilds = {
            "1456350064065904867" = {
              requireMention = false;
              channels = {
                # #botctls-test
                "1458426982579830908" = {
                  allow = true;
                  requireMention = false;
                  autoReply = true;
                };
                # #botributors-test (lurk only; replies denied via sendPolicy)
                "1458138963067011176" = {
                  allow = true;
                  requireMention = false;
                };
                # #botributors (lurk only; replies denied via sendPolicy)
                "1458141495701012561" = {
                  allow = true;
                  requireMention = false;
                };
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
        appId = "2607181";
        installationId = "102951645";
        privateKeyFile = "/run/agenix/botctl-github-app.pem";
        schedule = "hourly";
      };

      selfUpdate.enable = true;
      selfUpdate.flakePath = "/var/lib/bot/repo";
      selfUpdate.flakeHost = "botctl-1";

      githubSync.enable = true;

      cronJobsFile = ../../botctl/cron-jobs.json;
    };
  };
}
