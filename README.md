[![Build Status](https://travis-ci.org/tsoding/tsoder.svg?branch=master)](https://travis-ci.org/tsoding/tsoder)
[![codecov](https://codecov.io/gh/tsoding/tsoder/branch/master/graph/badge.svg)](https://codecov.io/gh/tsoding/tsoder)

# WARNING! CONTAINS SUBMODULES! CLONE RECURSIVELY!

```console
$ git clone --recursive git://github.com/tsoding/tsoder.git
```

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
$ docker create -e ACCESS_TOKEN="<access-token>" \
                -e TSODER_CHANNEL="<channel-name>" \
                --name morning-tsoding tsoder
$ docker start -a morning-tsoding
$ docker stop morning-tsoding
```

### Database Volume Backup

Tsoder Docker Image has a volume at `/tmp/tsoder.mnesia/` (see Dockerfile for more details) where the application keeps its database. The Dockerfile script creates the `/tmp/tsoder.mnesia` folder and initializes [Mnesia][mnesia] database inside of it with the `./scripts/create_db.erl` script. But if you want to constantly backup your database it is recommended to initialize the [Mnesia][mnesia] database outside of the Docker Image manually with `./scripts/create_db.erl` script:

```console
$ ./scripts/create_db.erl ./tsoder.mnesia/
```

And bind mount the external folder to `/tmp/tsoder.mnesia/` volume on the container creation:

```console
$ docker create -e ACCESS_TOKEN="<access-token>" \
                -e TSODER_CHANNEL="<channel-name>" \
                -v /absolute/path/to/tsoder.mnesia/:/tmp/tsoder.mnesia/ \
                --name morning-tsoding tsoder
```

[mnesia]: http://erlang.org/doc/apps/mnesia/Mnesia_chap2.html
