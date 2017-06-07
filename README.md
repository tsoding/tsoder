# tsoding-bot
Bot for Tsoding streams

## Build

### NixOS

```console
$ nix-shell
$ rebar3 compile
$ rebar3 shell
> application:start(tsoding_bot).
...
> application:stop(tsoding_bot).
```
