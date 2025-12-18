{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    unstable.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # home-manager

  }; # inputs

  outputs = { self, nixpkgs, home-manager, unstable, ... }:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {

      nixosConfigurations = {

        nixos = nixpkgs.lib.nixosSystem {

          inherit system;
          modules = [
            ./configuration.nix
            ./.hidden/boot_options.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              home-manager.users.afkara = import ./home.nix;
              home-manager.extraSpecialArgs = {
                unstablePkgs = import unstable { inherit system; };
              };

            }
          ]; # modules

        }; # nixpkgs.lib.nixosSystem

      }; # nixosConfigurations

    }; # outputs
}
