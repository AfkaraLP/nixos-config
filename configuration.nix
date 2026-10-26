# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

let
  omp = pkgs.stdenvNoCC.mkDerivation {
    pname = "omp";
    version = "18.13.0";

    src = pkgs.fetchurl {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v18.13.0/omp-linux-x64";
      hash = "sha256-eG9fdlIHnZciR+MRK6qoKOyHqufEw+rSDpl7e0yZ2V8=";
    };

    dontUnpack = true;
    installPhase = ''
      install -Dm755 "$src" "$out/libexec/omp"
      mkdir -p "$out/bin"
      cat > "$out/bin/omp" <<EOF
      #!${pkgs.runtimeShell}
      exec ${pkgs.stdenv.cc.bintools.dynamicLinker} \
        --library-path "${pkgs.lib.makeLibraryPath [
          pkgs.stdenv.cc.cc.lib
          pkgs.glibc
          pkgs.openssl
          pkgs.zlib
        ]}" \
        "$out/libexec/omp" "\$@"
      EOF
      chmod 755 "$out/bin/omp"
    '';

    dontPatchELF = true;
    dontStrip = true;
    doInstallCheck = true;
    installCheckPhase = ''
      HOME="$TMPDIR" "$out/bin/omp" --version
    '';
  };
in
{
  imports = [ # Include the results of the hardware scan.
    ./.hidden/hardware-configuration.nix
    ./default_programs.nix
  ];

  networking = {
    hostName = "nixos"; # Define your hostname.
    networkmanager.enable = true;
    dhcpcd.wait = "background";
    nameservers = [ "1.1.1.1" "9.9.9.9" ];
    firewall.allowedTCPPorts = [ 1234 ]; # LM Studio LAN API
  }; # networking

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.afkara = {
    isNormalUser = true;
    description = "afkara";
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" "dialout" ];
    packages = with pkgs; [ ];
  }; # users.users.afkara

  services = {
    saned.enable = false;
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      openFirewall = true;
    };
    tailscale = { enable = true; };
    flatpak.enable = true;
    fwupd.enable = true;
    udev.packages = with pkgs; [ via sane-backends ];
    xserver = {
      xkb = {
        layout = "us";
        variant = "workman";
      }; # xkb

      videoDrivers = [ "nvidia" ];
    }; # xserver

    getty.autologinUser = "afkara";

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      extraConfig.pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 1024;
          "default.clock.min-quantum" = 1024;
          "default.clock.max-quantum" = 2048;
        };
      };
      wireplumber = {
        configPackages = [
          (pkgs.writeTextDir
            "share/wireplumber/wireplumber.conf.d/11-bluetooth-policy.conf" ''
              wireplumber.settings = { bluetooth.autoswitch-to-headset-profile = false }
            '')
        ];
        extraConfig = {
          willsters-rage-at-handsfree-knows-no-rational-bounds = {
            "monitor.bluez.properties" = {
              "override.bluez5.roles" = [
                "a2dp_sink"
                "a2dp_source"
                "bap_sink"
                "bap_source"
                "hsp_hs"
                "hsp_ag"
                "hfp_ag"
              ];
            };
          };
          "10-bluez" = {
            "monitor.bluez.properties" = {
              "bluez5.enable-sbc-xq" = true;
              "bluez5.enable-msbc" = true;
              "bluez5.enable-hw-volume" = true;
              "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
            };
          };
        };
      };

    }; # pipewire

    pulseaudio.support32Bit = true;

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
          user = "greeter";
        };
      };
    };
  }; # services

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";

  environment = {
    etc."libinput/local-overrides.quirks".text = ''
      [Never Debounce]
      MatchUdevType=mouse
      ModelBouncingKeys=1
    '';
    systemPackages = with pkgs; [
      nvitop
      devenv
      proton-vpn-cli
      bat
      inputs.glide-browser.packages.x86_64-linux.default
      omp
      claude-code
      usbutils
      tldr
      tesseract
      lunar-client
      killall
      nixd
      nixfmt
      dconf
      sway-contrib.grimshot
      wl-clipboard
      easyeffects
      discord
      jujutsu
      lmstudio
      sane-backends
      simple-scan
      bottom
      wayfreeze
      (prismlauncher.override {
        jdks = [ temurin-bin-21 temurin-bin-17 temurin-bin-8 ];
        additionalPrograms = [ ffmpeg ];
        additionalLibs = [ pkgs.glfw ];
      })
      mangohud
      opencode
    ]; # systemPackages

    variables = {
      NIXOS_OZONE_WL = "1";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NVD_BACKEND = "direct";
      LIBVA_DRIVER_NAME = "nvidia";
    }; # variables
  }; # environment

  hardware = {
    sane = {
      enable = true;
      extraBackends = with pkgs; [ hplip sane-airscan sane-backends ];
    };
    nvidia = {
      open = false;
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      nvidiaSettings = true;
    }; # nvidia

    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [ nvidia-vaapi-driver ];
    }; # graphics

    bluetooth = {
      enable = true;
      settings = {
        General = {
          Name = "Hello";
          ControllerMode = "dual";
          FastConnectable = "true";
          Experimental = "true";
        }; # General
        Policy = { AutoEnable = "true"; }; # Policy
      }; # settings
    }; # bluetooth

  }; # hardware

  xdg.portal = {
    enable = true;
    configPackages = [ pkgs.hyprland ];
  }; # xdg.portal

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      auto-optimise-store = true;
      cores = 6;
      experimental-features = [ "nix-command" "flakes" ];
    };
  };
} # END
