{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    unstable.url = "nixpkgs/nixos-unstable";
    oldpkgs.url = "nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # home-manager

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  }; # inputs

  outputs = { self, nixpkgs, home-manager, unstable, oldpkgs, ... }:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {

      nixosConfigurations = {

        nixos = nixpkgs.lib.nixosSystem {

          inherit system;
          specialArgs = {
            oldpkgs = import oldpkgs {
              inherit system;
              config.allowUnfree = true;
            };
            newpkgs = import unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };

          modules = with self.inputs; [
            ./configuration.nix
            ./.hidden/boot_options.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              home-manager.users.afkara.imports =
                [ ./home.nix spicetify-nix.homeManagerModules.default ];
              home-manager.extraSpecialArgs = with self; {
                inherit inputs;
                unstablePkgs = import unstable { inherit system; };
              };

            }
          ]; # modules

        }; # nixpkgs.lib.nixosSystem

      }; # nixosConfigurations

    }; # outputs
}
