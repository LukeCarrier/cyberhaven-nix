{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption mkIf;
  cfg = config.services.cyberhaven;
in
{
  options.services.cyberhaven = {
    enable = mkEnableOption "cyberhaven";
    package = mkOption {
      type = lib.types.package;
      default = pkgs.cyberhaven;
      defaultText = lib.literalExpression "pkgs.cyberhaven";
      description = "The cyberhaven package to use.";
    };
    backend = mkOption {
      type = lib.types.str;
      description = "Backend URL";
      default = "https://c2f.cyberhaven.io";
    };
    installToken = mkOption {
      type = lib.types.str;
      description = "The install token for cyberhaven";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.cyberhaven = {
      description = "Cyberhaven";
      wants = [ "network-online.target" ];
      after = [
        "network.target"
        "network-online.target"
      ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = "root";
        ExecStart = "${cfg.package}/bin/cyberhaven '${cfg.backend}' '${cfg.installToken}'";
        KillMode = "process";
        KillSignal = "SIGKILL";
      };
    };
  };
}
