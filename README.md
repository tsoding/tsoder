# tsoding-bot

Bot for Tsoding streams

## Build

```console
$ rebar3 compile
$ rebar3 shell
> application:start(tsoding_bot).
...
> application:stop(tsoding_bot).
```

If you use NixOS we have a `default.nix` file at the root of the project for you to make your life easier.

## Unit Testing

```console
$ rebar3 eunit
```
