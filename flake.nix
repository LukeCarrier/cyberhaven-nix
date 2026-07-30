{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
        config.allowUnfreePredicate =
          pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "Cyberhaven" ];
      };
    in
    {
      packages.${system} = rec {
        inherit (pkgs) cyberhaven cyberhaven-unwrapped;
        default = cyberhaven;
      };

      overlays.default = import ./overlay.nix;

      nixosModules.cyberhaven = import ./cyberhaven-module.nix {
        cyberhaven-overlay = self.overlays.default;
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
