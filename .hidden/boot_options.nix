{ config, pkgs, lib, ... }:

{
  ### BOOT
  systemd = {
    services = {
      systemd-udev-settle.enable = false; # enable if stuff fails
      NetworkManager-wait-online.enable = false;
      systemd-timesyncd.enable = false;
      systemd-rfkill.enable = false;

      firewall = { wantedBy = [ "multi-user.target" ]; };

      nscd.serviceConfig.TimeoutStopSec = "2s";
      NetworkManager-wait-online.serviceConfig.TimeoutStopSec = "2s";
      nscd.enable = false;
      disable-wifi-on-boot = {
        restartIfChanged = false;
        after = [ "NetworkManager.service" ];
      };
    };
    tpm2.enable = false;
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };
  services = {
    ntp.enable = false;
    chrony.enable = true;
  };

  # Boot optimizations
  boot = {
    # Steam Frame's 28de:2432 adapter needs the in-tree rtw89_8852cu driver.
    kernelPackages = pkgs.linuxPackages_7_2;
    extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom=DE
    '';

    loader = {
      systemd-boot.configurationLimit = 10;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelParams = [ "rootflags=ro" "amd_pstate=active" "quiet" ];

    initrd = {
      compressor = "zstd";
      availableKernelModules = [ "nvme" "ext4" ];
    };
  };

  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = "\\xff\\xff\\xff\\xff\\x00\\x00\\x00\\x00\\xff\\xff\\xff";
    magicOrExtension = "\\x7fELF....AI\\x02";
  };
}
