{ config, pkgs, lib, ... }:

{
  ### BOOT
  systemd.services = {
    systemd-udev-settle.enable = false; # if all shit fails enable that again
    NetworkManager-wait-online.enable = false;
    "systemd-timesyncd".enable = false;
    nscd.serviceConfig.TimeoutStopSec = "3s";
    "NetworkManager-wait-online".serviceConfig.TimeoutStopSec = "5s";
    nscd.enable = false;
    # "systemd-timesyncd".wantedBy = lib.mkForce [ ];
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

    initrd = {
      compressor = "zstd";
      availableKernelModules = [ "nvme" "ext4" ];
    }; # initrd
  }; # boot
}
