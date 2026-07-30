final: prev: {
  cyberhaven-unwrapped = final.callPackage ./cyberhaven-unwrapped.nix { };
  cyberhaven = final.callPackage ./cyberhaven.nix { };
}
