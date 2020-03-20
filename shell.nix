{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc882" }:
let
  bootstrap = import <nixpkgs> {};

  nixpkgs = builtins.fromJSON (builtins.readFile ./nixpkgs.json);


  src = bootstrap.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    inherit (nixpkgs) rev sha256;
  };

  pkgs = import src {};
  inherit (pkgs) haskellPackages;
  inherit ((import ./default.nix).pre-commit-check) shellHook;

  myPackages = haskellPackages.callCabal2nix "project" ./haskell-graphql.cabal {};
  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};
in
haskellPackages.shellFor {
  # withHoogle = true;
  # shellHook = [shellHook];
  packages = p: [];
  buildInputs = with haskellPackages;
    [
      hlint
      ghcid
      cabal2nix
      stylish-haskell
      cabal-install
      cabal-fmt
      (all-hies.selection { selector = p: { inherit (p) ghc882; }; })
    ]
    ++ [
      pkgs.zlib
      pkgs.nixpkgs-fmt
    ];
}
