{
  cyberhaven-unwrapped,
  buildFHSEnv,
  writeShellScript,
  openssl,
}:
buildFHSEnv {
  pname = "cyberhaven";
  version = cyberhaven-unwrapped.version;

  targetPkgs = pkgs: [
    cyberhaven-unwrapped
    pkgs.openssl
  ];

  extraBwrapArgs = [
    "--ro-bind /home /home"
    "--tmpfs /etc/opt/cyberhaven"
    "--tmpfs /var/lib/cyberhaven"
  ];

  runScript = writeShellScript "cyberhaven" ''
    backend="$1"
    installToken="$2"
    shift 2

    echo ">>> Installing cyberhaven"
    ${cyberhaven-unwrapped}/opt/cyberhaven/cyberhaven --set-backend-url "$backend" --set-install-token "$installToken"

    echo ">>> Running cyberhaven"
    exec ${cyberhaven-unwrapped}/opt/cyberhaven/cyberhaven "$@"
  '';
}
