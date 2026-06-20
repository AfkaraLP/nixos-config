{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    ki-editor.url = "github:ki-editor/ki-editor";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # home-manager

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  }; # inputs

  outputs = { self, nixpkgs, home-manager, ki-editor, ... }@inputs:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {

      nixosConfigurations = {

        nixos = nixpkgs.lib.nixosSystem {

          inherit system;
          specialArgs = {
            inherit inputs;
          };

          modules = [
            ./configuration.nix
            ./.hidden/boot_options.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              home-manager.users.afkara.imports =
                [ ./home.nix inputs.spicetify-nix.homeManagerModules.default ];
              home-manager.extraSpecialArgs = { inherit inputs; };

            }
          ]; # modules

        }; # nixpkgs.lib.nixosSystem

      }; # nixosConfigurations

    }; # outputs
}
