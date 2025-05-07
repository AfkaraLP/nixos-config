{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixvim, ... }@inputs: {
    
    nixosConfigurations = {

      nixos = nixpkgs.lib.nixosSystem {

        system = "x86_64-linux";
        modules = [
          ./configuration.nix
	  ./default_programs.nix

	  home-manager.nixosModules.home-manager 
	  {
	    home-manager.useGlobalPkgs = true;
	    home-manager.useUserPackages = true;
	    home-manager.backupFileExtension = "backup";

	    home-manager.users.afkara = import ./home.nix;
	  }
        ];

	
      };

    };

  };
}
