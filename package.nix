{ pkgs
, zig ? pkgs.zig
, ... }:
let
  version = "2024";
in
pkgs.stdenv.mkDerivation {
  inherit version;
  pname = "aoc-${version}";
  name = "aoc";
  src = ./.;

  doCheck = true; # run tests

  configurePhase = ''
    export ZIG_GLOBAL_CACHE_DIR=$PWD/zig-cache/
  '';
  checkPhase = ''
    ${zig}/bin/zig build test
  '';
  buildPhase = ''
    ${zig}/bin/zig build -Doptimize=ReleaseSafe -Dcpu=baseline
  '';
  installPhase = ''
    cp $PWD/zig-out/bin/aoc $out
  '';
}
