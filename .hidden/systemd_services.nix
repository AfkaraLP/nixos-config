{ config, ... }:

{

  systemd.services.nix-gc-on-shutdown = {
    description = "Run Nix garbage collection on shutdown";
    wantedBy = [ "halt.target" "poweroff.target" "reboot.target" ];
    before = [ "shutdown.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.nix.package}/bin/nix-collect-garbage --delete-older-than 3d";
    };
  };
}
