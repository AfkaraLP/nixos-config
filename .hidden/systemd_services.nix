{ config, lib, pkgs, ... }:

{
  environment.etc."nix-gc-on-shutdown.sh".text = ''
    #!/bin/sh
    /nix/store/your-real-path-to-nix-collect-garbage --delete-older-than 3d
  '';

  systemd.services.nix-gc-on-shutdown = {
    description = "Run Nix garbage collection on shutdown";
    wantedBy = [ "halt.target" "poweroff.target" "reboot.target" ];
    before = [ "shutdown.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/etc/nix-gc-on-shutdown.sh";
    };
  };
}
