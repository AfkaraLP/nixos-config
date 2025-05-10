{ config, pkgs, lib, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
	position = "top";
	height = 35;
	margin = "10 5 0 5";

	modules-left = [ "cpu" "memory" ];
	modules-center = [ "custom/dadJoke" ];
	modules-right = [ "wireplumber" "clock" ];

	"cpu" = {
	  format = "CPU: {}";
	}; # "cpu" 

	"memory" = {
	  
	};

	"custom/dadJoke" = {
          format = "My Dad Once Said: {}";
          interval = 10;
	  max-length = 110;
          exec = pkgs.writeShellScript "dadJoke" ''
            joke=$(curl -H "Accept: text/plain" https://icanhazdadjoke.com/)
	    mkdir -p ./tmp
	    touch ./tmp/waybar-dadjoke.txt
	    echo "$joke" > ./tmp/waybar-dadjoke.txt
	    echo "$joke"
          '';
	  on-click-left = pkgs.writeShellScript "dadJokeReroll" ''
            joke=$(curl -H "Accept: text/plain" https://icanhazdadjoke.com/)
	    mkdir -p ./tmp
	    touch ./tmp/waybar-dadjoke.txt
	    echo "$joke" > ./tmp/waybar-dadjoke.txt
	    echo "$joke"
	  '';
	  on-click-right = pkgs.writeShellScript "dadJokeCopy" ''
	    cat ./tmp/waybar-dadjoke.txt | wl-copy
	  '';
        }; # "custom/dadJoke" 
      }; # mainBar 
    }; # settings 
    style = ''
	      * {
	  background-color: transparent;
	  color: #FFF;
	  margin: 0px;
	  padding: 0px;
	}

	/* alone */
	#custom-dadJoke {
	  background-color: rgba(0,0,0,0.5);
	  border: solid 2px rgba(58,58,58,0.66);
	  border-radius: 10px 10px 10px 10px;
	  margin: 0px 5px;
	  padding: 10px;
	}

	/* left */
	#cpu, #wireplumber {
	  background-color: rgba(0,0,0,0.5);
	  border: solid 2px rgba(58,58,58,0.66);
	  border-radius: 10px 0px 0px 10px;
	  margin: 0px 5px;
	  padding: 10px;
	}

	/* middle */
	#middle {
	  background-color: rgba(0,0,0,0.5);
	  border: solid 2px rgba(58,58,58,0.66);
	  border-radius: 0px 0px 0px 0px;
	  margin: 0px 5px;
	  padding: 10px;
	}

	/* right */
	#memory, #clock {
	  background-color: rgba(0,0,0,0.5);
	  border: solid 2px rgba(58,58,58,0.66);
	  border-radius: 0px 10px 10px 0px;
	  margin: 0px 5px;
	  padding: 10px;
	}
    '';
    # ENABLE THIS FOR DEBUG
    # systemd.enableInspect = true;
    # systemd.enable = true;
  }; # programs.waybar 
}
