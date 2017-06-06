let
  pkgs = import <nixpkgs> {};
  stdenv = pkgs.stdenv;
in rec {
  tsodingBotEnv = stdenv.mkDerivation rec {
    name = "tsoding-bot-env";
    version = "0.0.1";
    src = ./.;
    buildInputs = [ pkgs.erlang pkgs.rebar3-open ];
  };
}
