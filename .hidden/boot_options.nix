{ config, pkgs, lib, ... }:

{
  ### BOOT
  systemd = {
    services = {
      systemd-udev-settle.enable = false; # if all shit fails enable that again
      NetworkManager-wait-online.enable = false;
      systemd-timesyncd.enable = false;
      systemd-rfkill.enable = false;

      firewall = {
        # after = [ "network-online.target" ];
      	wantedBy = [ "multi-user.target" ];
      }; # "firewall" 

      nscd.serviceConfig.TimeoutStopSec = "2s";
      NetworkManager-wait-online.serviceConfig.TimeoutStopSec = "2s";
      nscd.enable = false;
      disable-wifi-on-boot = {
        restartIfChanged = false;
	after = [ "NetworkManager.service" ];
      };
    }; # services 
    tpm2.enable = false;
  }; # systemd.services
  services = {
    ntp.enable = false;
    chrony.enable = true;
  }; # services
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';
  ### BOOT

    boot = {
    loader = {
      systemd-boot.configurationLimit = 3;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    }; # loader

    kernelParams = [ "rootflags=ro" "fsck.mode=skip" ];

    initrd = {
      compressor = "zstd";
      availableKernelModules = [ "nvme" "ext4" ];
    }; # initrd
  }; # boot

  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
  }; # boot.binfmt.registrations.appimage 
}
