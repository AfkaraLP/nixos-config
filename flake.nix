{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # home-manager 

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # nixvim 
    
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # nixcord 
  }; # inputs 

  outputs = { self, nixpkgs, home-manager, nixvim, nixcord, ... }@inputs: {
    
    nixosConfigurations = {

      nixos = nixpkgs.lib.nixosSystem {

        system = "x86_64-linux";
        modules = [
          ./configuration.nix
	  ./default_programs.nix

	  nixvim.nixosModules.nixvim

	  home-manager.nixosModules.home-manager 
	  {
	    home-manager.useGlobalPkgs = true;
	    home-manager.useUserPackages = true;
	    home-manager.backupFileExtension = "backup";

	    home-manager.users.afkara = import ./home.nix;

	    home-manager.sharedModules = [
	      nixcord.homeModules.nixcord
	    ];
	  }
        ]; # modules 

	
      }; # nixpkgs.lib.nixosSystem 

    }; # nixosConfigurations 

  }; # outputs 
}
