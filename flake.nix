{
  description = "Jerry's nix";

  inputs = {
    # Package sets
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-23.05-darwin";
    nixpkgs-unstable.url = github:NixOS/nixpkgs/nixpkgs-unstable;

    # Environment/system management
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Other sources
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, darwin, home-manager, flake-utils, ... }@inputs:
  let
    inherit (darwin.lib) darwinSystem;
    inherit (inputs.nixpkgs-unstable.lib) attrValues makeOverridable optionalAttrs singleton;

    # Configuration for `nixpkgs`
    nixpkgsConfig = {
      config = {
        allowUnfree = true;
      };
    };
  in
  {
    # `nix-darwin` configs
    darwinConfigurations = rec {
      myOtherMac = darwinSystem {
        system = "aarch64-darwin";
        modules = [
          # Main `nix-darwin` config
          ./my-other-mac/configuration.nix
          # `home-manager` module
          home-manager.darwinModules.home-manager {
            nixpkgs = nixpkgsConfig;
            # `home-manager` config
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jerry = import ./home.nix;
          }
        ];
      };
    };

    homeConfigurations = {
      "jerry@server" = home-manager.lib.homeManagerConfiguration rec {
        pkgs = nixpkgs-unstable.legacyPackages.x86_64-linux;
        modules = [
          ./home.nix
          {
            home = {
              username = "jerry";
              homeDirectory = "/home/jerry";
              stateVersion = "23.05";
              enableNixpkgsReleaseCheck = false;
            };
          }
        ];
      };
      "jerry@rpi" = home-manager.lib.homeManagerConfiguration rec {
        pkgs = nixpkgs-unstable.legacyPackages.aarch64-linux;
        modules = [
          ./home.nix
          {
            home = {
              username = "jerry";
              homeDirectory = "/home/jerry";
              stateVersion = "23.05";
              enableNixpkgsReleaseCheck = false;
            };
          }
        ];
      };
    };

    overlays = {
    };
  };
}
