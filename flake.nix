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
  }; # inputs 

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
        ]; # modules 

	
      }; # nixpkgs.lib.nixosSystem 

    }; # nixosConfigurations 

  }; # outputs 
}
