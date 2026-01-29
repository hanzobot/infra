{
  description = "Example BOTCTL host flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-bot.url = "github:bot/nix-bot"; # latest upstream
    agenix.url = "github:ryantm/agenix";
    secrets = {
      url = "path:../../../nix/nix-secrets";
      flake = false;
    };
    botctls.url = "path:../..";
  };

  outputs = { self, nixpkgs, nix-bot, agenix, secrets, botctls }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.botctl-1 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit secrets; };
        modules = [
          ({ pkgs, ... }: { nixpkgs.overlays = [ botctls.overlays.default ]; })
          agenix.nixosModules.default
          botctls.nixosModules.botctl
          ./botctl-host.nix
        ];
      };
    };
}
