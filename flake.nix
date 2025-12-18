{
  description = "Jerry's nix";

  inputs = {
    # Package sets
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Environment/system management
    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, darwin, home-manager, ... }@inputs:
  let
    inherit (darwin.lib) darwinSystem;
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
            home-manager.users.jerry = {
              imports = [
                ./home/common.nix
                ./home/darwin.nix
              ];
            };
          }
        ];
      };
    };

    homeConfigurations = {
      "root@wsl" = home-manager.lib.homeManagerConfiguration rec {
        pkgs = nixpkgs-unstable.legacyPackages.x86_64-linux;
        modules = [
          ./home/common.nix
          ./home/linux.nix
          {
            home = {
              username = "root";
              homeDirectory = "/root";
              stateVersion = "25.05";
              enableNixpkgsReleaseCheck = false;
            };
          }
        ];
      };
      "jerry@server" = home-manager.lib.homeManagerConfiguration rec {
        pkgs = nixpkgs-unstable.legacyPackages.x86_64-linux;
        modules = [
          ./home/common.nix
          ./home/linux.nix
          {
            home = {
              username = "jerry";
              homeDirectory = "/home/jerry";
              stateVersion = "25.05";
              enableNixpkgsReleaseCheck = false;
            };
          }
        ];
      };
      "jerry@rpi" = home-manager.lib.homeManagerConfiguration rec {
        pkgs = nixpkgs-unstable.legacyPackages.aarch64-linux;
        modules = [
          ./home/common.nix
          ./home/linux.nix
          {
            home = {
              username = "jerry";
              homeDirectory = "/home/jerry";
              stateVersion = "25.05";
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
