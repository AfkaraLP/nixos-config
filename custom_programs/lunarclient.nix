{ config, pkgs, ... }:

let
  lunarClient = pkgs.appimageTools.wrapType2 {
      pname = "lunar-client";
      version = "3.3.10";
      src = pkgs.fetchurl {
        url = "https://launcherupdates.lunarclientcdn.com/Lunar%20Client-${version}-ow.AppImage";
        sha256 = "<use a temporary wrong hash here>";
      };
      extraPkgs = pkgs: with pkgs; [
        libGL xorg.libX11 libepoxy libthai
      ];
      extraInstallCommands = ''
        mkdir -p $out/share/applications
        install -Dm644 $src.desktop $out/share/applications/${pname}.desktop
        substituteInPlace $out/share/applications/${pname}.desktop \
          --replace 'Exec=AppRun' 'Exec=${pname}'
      '';
    };
  };
in
{
  environment.systemPackages = with pkgs; [
    lunarClient
  ];
}
