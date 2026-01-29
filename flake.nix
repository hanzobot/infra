{
  description = "BOTCTL infra + Nix modules";

  inputs = {
    nix-bot.url = "github:bot/nix-bot"; # latest upstream
    nixpkgs.follows = "nix-bot/nixpkgs";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, nix-bot, agenix }:
    let
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: lib.genAttrs systems (system: f system);
      botOverlay = nix-bot.overlays.default;
    in
    {
      nixosModules.botctl = import ./nix/modules/botctl.nix;
      nixosModules.default = self.nixosModules.botctl;

      overlays.bot = botOverlay;
      overlays.default = botOverlay;

      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
          gateway =
            if pkgs ? botd
            then pkgs.botd
            else pkgs.bot;
          systemPackages =
            if system == "x86_64-linux" then {
              botctl-system = self.nixosConfigurations.botctl-1.config.system.build.toplevel;
              botctl-image-system = self.nixosConfigurations.botctl-1-image.config.system.build.toplevel;
            } else {};
        in {
          botd = gateway;
          default = gateway;
        } // systemPackages);

      nixosConfigurations.botctl-1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ ... }: { nixpkgs.overlays = [ self.overlays.default ]; })
          agenix.nixosModules.default
          ./nix/hosts/botctl-1.nix
        ];
      };

      nixosConfigurations.botctl-1-image = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ ... }: { nixpkgs.overlays = [ self.overlays.default ]; })
          agenix.nixosModules.default
          ./nix/hosts/botctl-1-image.nix
        ];
      };
    };
}
