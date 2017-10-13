[![Build Status](https://travis-ci.org/tsoding/tsoder.svg?branch=master)](https://travis-ci.org/tsoding/tsoder)
[![codecov](https://codecov.io/gh/tsoding/tsoder/branch/master/graph/badge.svg)](https://codecov.io/gh/tsoding/tsoder)

# tsoder

Bot for Tsoding streams

![tsoder](https://raw.githubusercontent.com/tsoding/tsoder-brand/master/images/logo.png)

## Quick Start

```console
$ ./scripts/create_db.erl /tmp/tsoder.mnesia/ # initializing database (see config/sys.config)
$ ACCESS_TOKEN="<twitch-access-token>" TSODER_CHANNEL="<twitch-channal>" rebar3 shell --name tsoder@node
```

If you use NixOS we have a `default.nix` file at the root of the project for you to make your life easier.

## Unit Testing

```console
$ rebar3 eunit
```

## Docker

```console
$ docker build -t tsoder .
$ docker create -e ACCESS_TOKEN="<access-token>" -e TSODER_CHANNEL="<channel-name>" --name morning-tsoding tsoder
$ docker start morning-tsoding
$ docker stop morning-tsoding
```
