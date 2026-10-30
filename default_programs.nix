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
    (pkgs.bs-manager.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        # Current Steam clients no longer run steam-runtime-launcher-service.
        substituteInPlace src/main/services/steam.service.ts \
          --replace-fail 'getProcessId, isProcessRunning' 'bsmExec, getProcessId, isProcessRunning' \
          --replace-fail 'const steamProcessRunning = await isProcessRunning(SteamService.PROCESS_NAME);' \
            'const steamProcessRunning = process.platform === "linux" ? !!(await this.getSteamPid()) : await isProcessRunning(SteamService.PROCESS_NAME);' \
          --replace-fail 'return getProcessId(SteamService.PROCESS_NAME);' \
            'if (process.platform === "linux") {
                const result = await bsmExec(`pgrep -o -u ''${process.getuid!()} -x steam`).catch(() => null);
                return result ? Number(result.stdout) : 0;
            }
            return getProcessId(SteamService.PROCESS_NAME);'
      '';
    }))
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
  # Vicinae snippets read keyboard events and inject replacement text.
  users.users.afkara.extraGroups = [ "input" "uinput" ];

}

