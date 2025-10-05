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

        modules-left = [ "cpu" "custom/gpu" "memory" ];
        modules-center = [ "custom/dadJoke" ];
        modules-right = [ "wireplumber" "clock" ];

        wireplumber = {
          format = "{volume}%";
          format-muted = "ded";
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-click-right = ''
            #!/usr/bin/env bash
            # 
            choice=$(wpctl status \
              | awk '
                /Sinks:/ { in_sinks=1; next }
                /Sources:/ { in_sinks=0 }
                in_sinks && /^[[:space:]]*│/ {
                  id=$2
                  # Extract name starting from the 3rd field until "[vol:"
                  name=""
                  for (i=3; i<=NF; i++) {
                    if ($i ~ /^\[vol:/) break
                    name = name $i " "
                  }
                  sub(/[ \t]+$/, "", name)
                  print id " " name
                }
              ' \
              | fuzzel --dmenu --prompt "Select Sink:")

            if [ -n "$choice" ]; then
                sink_id=$(echo "$choice" | awk '{print $1}')
                wpctl set-default "$sink_id"
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

        "custom/gpu" = {
          format = "gpu: {}°C";
          interval = 5;
          exec = pkgs.writeShellScript "gpu" ''
            nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits
          '';
        };

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
      #middle, #custom-gpu {
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
