{ mkDerivation
, base
, bytestring
, morpheus-graphql
, scotty
, stdenv
, text
}:
mkDerivation {
  pname = "haskell-graphql";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base
    bytestring
    morpheus-graphql
    scotty
    text
  ];
  license = "unknown";
  hydraPlatforms = stdenv.lib.platforms.none;
}
