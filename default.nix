let
  pkgs = import <nixpkgs> {};
  stdenv = pkgs.stdenv;
in rec {
  tsoderEnv = stdenv.mkDerivation rec {
    name = "tsoder-env";
    version = "0.0.1";
    src = ./.;
    buildInputs = [ pkgs.erlang pkgs.rebar3-open pkgs.gnumake pkgs.imagemagick ];
  };
}
