#!/usr/bin/env escript
%%! -name tsoder@node

-include("../src/unique_ids.hrl").
-include("../src/fart_rating.hrl").
-include("../src/quote_database.hrl").

%% TODO(#106): create_db.erl should always use mnesia dir defined in `./config/sys.config`
main([MnesiaDir]) ->
    error_logger:info_report([{node, node()},
                              {mnesia_dir, MnesiaDir}]),
    application:set_env(mnesia, dir, MnesiaDir),
    ok = mnesia:create_schema([node()]).
