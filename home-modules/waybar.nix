{ config, pkgs, lib, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        output = [ "DP-1" "DP-2" "DP-3" ];
        layer = "top";
        position = "top";
        height = 35;
        margin = "10 5 0 5";

        modules-left = [ "cpu" "memory" ];
        modules-center = [ "custom/dadJoke" ];
        modules-right = [ "wireplumber" "clock" ];

        wireplumber = {
          format = "{volume}%";
          format-muted = "ded";
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-click-right = ''
            #!/usr/bin/env bash
            sinks="71
            88"

            choice=$(echo "$sinks" | wofi --show dmenu --prompt "Select Sink:")

            if [ -n "$choice" ]; then
              wpctl set-default "$choice"
            fi
          '';
        };

        cpu = {
          interval = 1;
          format = "cpu: {usage}%";
        }; # "cpu"

        clock = {
          tooltip = true;
          tooltip-format = "{:%Y-%m-%d}";
        };

        memory = {
          interval = 5;
          format = "{used:0.1f}/{total:0.1f}GiB";
        }; # "memory"

        "custom/dadJoke" = {
          format = "My Dad Once Said: {}";
          interval = 10;
          max-length = 110;
          exec = pkgs.writeShellScript "dadJoke" ''
                  # joke=$(curl -H "Accept: text/plain" https://icanhazdadjoke.com/ | sed -z 's/[\n\r]+/, /g')
                  joke=$(curl -H "Accept: text/plain" https://icanhazdadjoke.com/ | tr -d '\n' | tr -d '\r')
            	    mkdir -p ~/.tmp
            	    touch ~/.tmp/waybar-dadjoke.txt
            	    echo "$joke" > ~/.tmp/waybar-dadjoke.txt
            	    echo "$joke"
          '';
          on-click-left = pkgs.writeShellScript "dadJokeReroll" ''
                  # joke=$(curl -H "Accept: text/plain" https://icanhazdadjoke.com/ | sed -z 's/[\n\r]+/, /g')
                  joke=$(curl -H "Accept: text/plain" https://icanhazdadjoke.com/ | tr -d '\n' | tr -d '\r')
            	    mkdir -p ~/.tmp
            	    touch ~/.tmp/waybar-dadjoke.txt
            	    echo "$joke" > ~/.tmp/waybar-dadjoke.txt
            	    echo "$joke"
            	  '';
          on-click-right = pkgs.writeShellScript "dadJokeCopy"
            "  cat ~/.tmp/waybar-dadjoke.txt | wl-copy\n";
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
