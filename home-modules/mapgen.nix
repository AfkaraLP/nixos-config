# Beat Saber map generator server for the in-game "AI Map Gen" mod (BSManager instance, Plugins/AIMapGen.dll).
# Socket-activated: nothing runs (and no VRAM is held) until the mod connects to 127.0.0.1:8790; the server then
# starts from the project checkout (~8 s to first response, ~15 s until the model is loaded) and exits again
# after 20 idle minutes. Logs: journalctl --user -u mapgen
{ ... }:
let
  root = "/home/afkara/projects/ai_training/beatsaber-mapgen-250m";
in
{
  systemd.user.sockets.mapgen = {
    Unit.Description = "Beat Saber mapgen server socket";
    Socket.ListenStream = "127.0.0.1:8790";
    Install.WantedBy = [ "sockets.target" ];
  };

  systemd.user.services.mapgen = {
    Unit = {
      Description = "Beat Saber mapgen server (YouTube / SoundCloud -> generated maps)";
      Requires = [ "mapgen.socket" ];
    };
    Service = {
      WorkingDirectory = root;
      Environment = [ "MAPGEN_ROOT=${root}" ];
      ExecStart = "/run/current-system/sw/bin/nix run ${root}#default -- --idle-exit 1200";
      Nice = 5;
    };
  };
}
