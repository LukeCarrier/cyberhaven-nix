{
  stdenv,
  requireFile,
  autoPatchelfHook,
  dpkg,
  openssl,
  libgcc,
  xz,
  zlib,
  bzip2,
  keyutils,
  buildFHSEnv,
  writeShellScript,
}:
let
  cyberhaven = stdenv.mkDerivation rec {
    pname = "cyberhaven";
    version = "24.09.03.91";
    ref = "0dbc90";

    src = requireFile {
      name = "Cyberhaven-${version}-${ref}.deb";
      url = "https://drive.google.com/drive/folders/12cIRewEoypqr0f5jmAXMW_iXZumTLf9h";
      sha256 = "dfc1553ad831599d23854150d9ac5f38e4b0826fbfc038d3916b1eee844fe119";
    };

    nativeBuildInputs = [
      autoPatchelfHook
      dpkg
    ];

    buildInputs = [
      openssl
      libgcc.lib
      xz
      zlib
      bzip2
      keyutils.lib
    ];

    installPhase = ''
      runHook preInstall

      dpkg -X $src $out
      rm $out/opt/cyberhaven/lib/libcyberhavennet-legacy.so

      runHook postInstall
    '';
  };
in
buildFHSEnv {
  name = cyberhaven.pname;

  targetPkgs = pkgs: [
    cyberhaven
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
    ${cyberhaven}/opt/cyberhaven/cyberhaven --set-backend-url "$backend" --set-install-token "$installToken"

    echo ">>> Running cyberhaven"
    exec ${cyberhaven}/opt/cyberhaven/cyberhaven "$@"
  '';
}
