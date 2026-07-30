{ cyberhaven-overlay }:
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
    backend = mkOption {
      type = lib.types.str;
      description = "Backend URL";
      default = "https://c2f.cyberhaven.io";
    };
    backendFile = mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a file containing the backend URL, read at runtime. Takes
        precedence over `backend`. Use this to keep the value out of the
        world-readable Nix store (e.g. with sops-nix).
      '';
    };
    installToken = mkOption {
      type = lib.types.str;
      default = "";
      description = "The install token for cyberhaven";
    };
    installTokenFile = mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a file containing the install token, read at runtime. Takes
        precedence over `installToken`. Use this to keep the token out of the
        world-readable Nix store (e.g. with sops-nix).
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.installToken != "" || cfg.installTokenFile != null;
        message = "services.cyberhaven: set either installToken or installTokenFile.";
      }
    ];

    nixpkgs.overlays = [ cyberhaven-overlay ];

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
        ExecStart = pkgs.writeShellScript "cyberhaven-start" ''
          ${
            if cfg.backendFile != null
            then ''backend="$(cat ${cfg.backendFile})"''
            else ''backend=${lib.escapeShellArg cfg.backend}''
          }
          ${
            if cfg.installTokenFile != null
            then ''token="$(cat ${cfg.installTokenFile})"''
            else ''token=${lib.escapeShellArg cfg.installToken}''
          }
          exec ${pkgs.cyberhaven}/bin/cyberhaven "$backend" "$token"
        '';
        KillMode = "process";
        KillSignal = "SIGKILL";
      };
    };
  };
}
