[![Build Status](https://travis-ci.org/tsoding/tsoder.svg?branch=master)](https://travis-ci.org/tsoding/tsoder)
[![codecov](https://codecov.io/gh/tsoding/tsoder/branch/master/graph/badge.svg)](https://codecov.io/gh/tsoding/tsoder)

# tsoder

Bot for Tsoding streams

![tsoder](https://raw.githubusercontent.com/tsoding/tsoder-brand/master/images/logo.png)

## Build

```console
$ rebar3 compile
$ rebar3 shell
> application:start(tsoder).
...
> application:stop(tsoder).
```

If you use NixOS we have a `default.nix` file at the root of the project for you to make your life easier.

## Unit Testing

```console
$ rebar3 eunit
```

<!-- TODO(#76): Document the docker related stuff:

- How to build an image
- How to run the container
- etc

-->
