{ config, pkgs, lib, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
	position = "top";
	height = 35;
	margin = "10 10 0 10";

	modules-left = [ "cpu#left" "memory#right" ];
	modules-center = [ "custom/dadJoke#alone" ];
	modules-right = [ "wireplumber#left" "clock#right" ];

	"cpu" = {
	  format = "CPU: {}";
	}; # "cpu" 

	"memory" = {
	  
	};

	"custom/dadJoke" = {
          format = "my dad once said: {}";
          interval = 10;
          exec = pkgs.writeShellScript "dadJoke" ''
            curl -H "Accept: text/plain" https://icanhazdadjoke.com/
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
	  overflow: hidden;
	  height: 30px;
	  box-sizing: border-box;
	}

	*:before, *:after {
	  margin: 0;
	  padding: 0;
	}


	/* alone */
	#alone {
	  background-color: rgba(0,0,0,0.5);
	  border: solid 2px rgba(58,58,58,0.66);
	  border-radius: 10px 10px 10px 10px;
	  margin: 0px 5px;
	  padding: 5px;
	}

	/* left */
	#left {
	  background-color: rgba(0,0,0,0.5);
	  border: solid 2px rgba(58,58,58,0.66);
	  border-radius: 10px 0px 0px 10px;
	  margin: 0px 5px;
	  padding: 5px;
	}

	/* middle */
	#middle {
	  background-color: rgba(0,0,0,0.5);
	  border: solid 2px rgba(58,58,58,0.66);
	  border-radius: 0px 0px 0px 0px;
	  margin: 0px 5px;
	  padding: 5px;
	}

	/* right */
	#right {
	  background-color: rgba(0,0,0,0.5);
	  border: solid 2px rgba(58,58,58,0.66);
	  border-radius: 0px 10px 10px 0px;
	  margin: 0px 5px;
	  padding: 5px;
	}
    '';
    # ENABLE THIS FOR DEBUG
    # systemd.enableInspect = true;
    # systemd.enable = true;
  }; # programs.waybar 
}
