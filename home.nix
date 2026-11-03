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
  flStudioRuntime = (pkgs.steam.override { privateTmp = false; }).run;

  # Install/update the official Image-Line Windows installer in this per-user
  # prefix; Nix manages the Wine runtime and launcher, not the licensed app files.
  # Provision corefonts in that same prefix: FLEX needs Arial/Verdana font files.
  flStudio = pkgs.writeShellApplication {
    name = "fl-studio";
    runtimeInputs = [ pkgs.coreutils flStudioRuntime ];
    text = ''
      export WINEPREFIX="''${XDG_DATA_HOME:-$HOME/.local/share}/fl-studio"
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
      exec steam-run "${flStudioWine}/bin/wine" \
        "$WINEPREFIX/drive_c/Program Files/Image-Line/FL Studio 2026/FL64.exe" "''${args[@]}"
    '';
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

  xdg.desktopEntries.fl-studio = {
    name = "FL Studio";
    comment = "Music production (Wine)";
    exec = "${flStudio}/bin/fl-studio %F";
    icon = "2354_FL64.0";
    categories = [ "AudioVideo" "Audio" "Midi" "Sequencer" ];
    startupNotify = true;
    settings.StartupWMClass = "fl64.exe";
  };

  xdg.configFile."wpaperd/wallpaper.toml".source =
    (pkgs.formats.toml { }).generate "wallpaper_config_afkara" wallpaperConfig;

  # Use SteamVR's live manifest so OpenXR follows Steam-managed runtime updates.
  xdg.configFile."openxr/1/active_runtime.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.local/share/Steam/steamapps/common/SteamVR/steamxr_linux64.json";

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
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
