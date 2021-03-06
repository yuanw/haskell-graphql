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
  myHaskellPackages = pkgs.haskell.packages."${compiler}".override {
    overrides = self: super: rec {
      haskell-graphql = self.callPackage ./haskell-graphql.nix {};
    };
  };
in
{
  haskell-graphql = myHaskellPackages.haskell-graphql;
}
