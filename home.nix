{ config, pkgs, ... }:
let
  # Pinned audio-focused Wine: DirectComposition/WebView2 and FL signature fixes.
  flStudioWine = pkgs.runCommand "fl-studio-wine-mozart-0.0.2" {
    src = pkgs.fetchurl {
      url = "https://github.com/HeapHeapHooray/wine-mozart/releases/download/v0.0.2/wine-mozart-11.0-x86_64.tar.xz";
      sha256 = "a2cfb27f795fb714f98cb9fdb058e41359f942a179644a7a4cec0f616320f85d";
    };
    nativeBuildInputs = [ pkgs.xz ];
  } ''
    mkdir -p "$out"
    tar -xJf "$src" --strip-components=1 -C "$out"
  '';

  # Wine's /tmp socket must be shared across launches of the same prefix.
  flStudioRuntime = (pkgs.steam.override {
    privateTmp = false;
    # Wine needs XComposite to redirect hosted plugin GL child windows.
    extraPkgs = pkgs: [ pkgs.libxcomposite ];
  }).run;

  # Vital 1.5.5's VST3 editor crashes Wine hosts on close; use its matching VST2.
  vitalWindows = pkgs.runCommand "vital-windows-vst2-1.5.5" {
    src = pkgs.fetchurl {
      url = "https://builds.vital.audio/VitalAudio/vital/1_5_5/VitalInstaller.exe";
      sha256 = "9ba511319cb3da891338957388bc74d860c7eaa78dcb192d9fe7b70960c29ab3";
    };
    nativeBuildInputs = [ pkgs.innoextract ];
  } ''
    innoextract --silent --extract --include 'code$GetVST64Dir/Vital.dll' "$src"
    install -Dm644 'code$GetVST64Dir/Vital.dll' "$out/Vital.dll"
  '';

  # Install/update the official Image-Line Windows installer in this per-user
  # prefix; Nix manages the Wine runtime and launcher, not the licensed app files.
  # Provision corefonts in that same prefix: FLEX needs Arial/Verdana font files.
  flStudio = pkgs.writeShellApplication {
    name = "fl-studio";
    runtimeInputs = [ pkgs.coreutils flStudioRuntime ];
    text = ''
      export WINEPREFIX="''${XDG_DATA_HOME:-$HOME/.local/share}/fl-studio"
      # Leftover winedevice.exe stops reading the system bus but stays connected;
      # its queued signals exhaust the per-user quota and crash steamwebhelper.
      export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/dev/null
      # Store timestamps cannot identify Wine upgrades reliably.
      if [[ ! -f "$WINEPREFIX/.fl-studio-runtime" ]] ||
         [[ "$(< "$WINEPREFIX/.fl-studio-runtime")" != "${flStudioWine}" ]]; then
        (cd "$HOME" && steam-run "${flStudioWine}/bin/wineboot" -u)
        printf '%s\n' "${flStudioWine}" > "$WINEPREFIX/.fl-studio-runtime"
      fi
      # FHS may omit the caller's directory; preserve relative project arguments.
      args=()
      for arg in "$@"; do
        if [[ -f "$arg" ]]; then
          path="$(realpath -- "$arg")"
          arg="$(cd "$HOME" && steam-run "${flStudioWine}/bin/winepath" -w "$path")"
        fi
        args+=("$arg")
      done
      cd "$HOME"
      # Vital's editor is black with Mozart's EGL backend; use native GLX for FL.
      steam-run "${flStudioWine}/bin/wine" reg add \
        'HKCU\Software\Wine\AppDefaults\FL64.exe\X11 Driver' \
        /v UseEGL /t REG_SZ /d N /f >/dev/null
      exec steam-run "${flStudioWine}/bin/wine" \
        "$WINEPREFIX/drive_c/Program Files/Image-Line/FL Studio 2026/FL64.exe" "''${args[@]}"
    '';
  };

  flStudioDesktop = pkgs.makeDesktopItem {
    name = "fl-studio";
    desktopName = "FL Studio";
    comment = "Music production (Wine)";
    exec = "${flStudio}/bin/fl-studio %F";
    icon = "2354_FL64.0";
    categories = [ "AudioVideo" "Audio" "Midi" "Sequencer" ];
    startupNotify = true;
    extraConfig.StartupWMClass = "fl64.exe";
  };

  wallpaperConfig = {
    default = {
      path = "/home/afkara/wallpapers";
      duration = "1m";
      sorting = "random";
    }; # default
  }; # wallpaperConfig
in {
  home.username = "afkara";
  home.homeDirectory = "/home/afkara";

  imports = [
    ./home-modules/terminal.nix
    ./home-modules/assets/fonts.nix
    ./home-modules/waybar.nix
    ./home-modules/assets/themes.nix
    ./home-modules/fuzzel.nix
    ./home-modules/helix.nix
    ./home-modules/spicetify.nix
    ./home-modules/discord.nix
  ]; # imports

  home.packages = [ flStudio ];
  home.file.".vst/Vital.dll".source = "${vitalWindows}/Vital.dll";

  xdg.dataFile."applications/fl-studio.desktop".source =
    "${flStudioDesktop}/share/applications/fl-studio.desktop";

  # Imported by Hyprland's config/rules.lua; keep the Wine owner out of focus.
  xdg.configFile."hypr/config/fl-studio.lua".source =
    ./home-modules/assets/fl-studio.lua;

  xdg.configFile."wpaperd/wallpaper.toml".source =
    (pkgs.formats.toml { }).generate "wallpaper_config_afkara" wallpaperConfig;

  # Use SteamVR's live manifest so OpenXR follows Steam-managed runtime updates.
  xdg.configFile."openxr/1/active_runtime.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.local/share/Steam/steamapps/common/SteamVR/steamxr_linux64.json";

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "glide.desktop" ];
      "application/xhtml+xml" = [ "glide.desktop" ];
      "x-scheme-handler/http" = [ "glide.desktop" ];
      "x-scheme-handler/https" = [ "glide.desktop" ];
      "x-scheme-handler/bsmanager" = [ "BSManager.desktop" ];
      "x-scheme-handler/beatsaver" = [ "BSManager.desktop" ];
      "x-scheme-handler/bsplaylist" = [ "BSManager.desktop" ];
      "x-scheme-handler/modelsaber" = [ "BSManager.desktop" ];
      "x-scheme-handler/web+bsmap" = [ "BSManager.desktop" ];
    };
  };
  services = {
    wpaperd = {
      enable = true;
      settings = { };
    }; # wpaperd
  }; # services

  home.stateVersion = "24.11";

  programs = { home-manager.enable = true; }; # programs
}
