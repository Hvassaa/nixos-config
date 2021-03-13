{config, lib, pkgs, ...}:

with lib;

let 
  cfg = config.services.touchegg;
  touchegg = pkgs.callPackage ./touchegg.nix {};
in {
  options.services.touchegg = {
    enable = mkEnableOption "Whether to enable touchegg.";
  };

  config = mkIf cfg.enable {
    systemd.services.touchegg = {
      description = "Touchégg Daemon";
      documentation = [ "https://github.com/JoseExposito/touchegg/tree/master/installation#readme" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        Group = "input";
        ExecStart = "${touchegg}/bin/touchegg --daemon";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
    environment.systemPackages = [ touchegg ];
  };
}
