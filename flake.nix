{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # home-manager 
   
  }; # inputs 

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    
    nixosConfigurations = {

      nixos = nixpkgs.lib.nixosSystem {

        system = "x86_64-linux";
        modules = [
          ./configuration.nix
      	  ./default_programs.nix
      	  ./.hidden/boot_options.nix

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
