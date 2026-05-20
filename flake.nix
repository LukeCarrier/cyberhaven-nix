{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      cyberhaven-unwrapped = pkgs.callPackage ./cyberhaven-unwrapped.nix { };
      cyberhaven = pkgs.callPackage ./cyberhaven.nix { inherit cyberhaven-unwrapped; };
    in
    {
      packages.${system} = {
        inherit cyberhaven cyberhaven-unwrapped;
        default = cyberhaven;
      };

      nixosModules.cyberhaven = ./cyberhaven-module.nix;

      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
