{ config, lib, pkgs, ... }:

{
  programs = {
    alvr = {
      enable = true;
      openFirewall = true;
    };
    gamemode.enable = true;
    gamescope = {
      enable = true;
      capSysNice = true;
    };

    hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };


    steam = {
      enable = true;
      # Wayland capture is required over both LAN Wi-Fi and the Frame adapter.
      package = pkgs.steam.override { extraArgs = "-pipewire"; };
      remotePlay.openFirewall = true;
    };

    git.enable = true;

    yazi = { enable = true; }; # yazi

  }; # programs

  environment.systemPackages = [
    pkgs.bs-manager
    # Wayland desktop overlay; SteamVR's built-in desktop view is unreliable.
    (pkgs.symlinkJoin {
      name = "wayvr-steamvr";
      paths = [ pkgs.wayvr ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        rm "$out/bin/wayvr"
        makeWrapper ${lib.getExe pkgs.steam-run} "$out/bin/wayvr" \
          --add-flags "${lib.getExe pkgs.wayvr} --openvr"
      '';
    })
  ];
  hardware.uinput.enable = true;
  users.users.afkara.extraGroups = [ "uinput" ];

}

