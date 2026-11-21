{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # home-manager

    glide-browser.url = "github:glide-browser/glide.nix";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    nixcord.url = "github:kaylorben/nixcord";

    # Wine -> native file drags for FL Studio; local checkout until published.
    wine-native-dnd = {
      url = "git+file:///home/afkara/projects/wine-native-dnd?ref=worktree-dnd-bridge";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  }; # inputs

  outputs = { self, nixpkgs, home-manager, glide-browser, ... }@inputs:

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
                [
                  ./home.nix
                  inputs.spicetify-nix.homeManagerModules.default
                  inputs.nixcord.homeModules.nixcord
                ];
              home-manager.extraSpecialArgs = { inherit inputs; };

            }
          ]; # modules

        }; # nixpkgs.lib.nixosSystem

      }; # nixosConfigurations

    }; # outputs
}
