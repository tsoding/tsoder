#!/usr/bin/env escript
%%! -name tsoder@node

-include("../src/fart_rating.hrl").

%% TODO(#106): create_db.erl should always use mnesia dir defined in `./config/sys.config`
%% TODO: implement mnesia schema migrations
main([MnesiaDir]) ->
    error_logger:info_report([{node, node()},
                              {mnesia_dir, MnesiaDir}]),
    application:set_env(mnesia, dir, MnesiaDir),
    ok = mnesia:create_schema([node()]),
    ok = mnesia:start(),
    {atomic, ok} = mnesia:create_table(fart_rating,
                                       [{attributes, record_info(fields, fart_rating)},
                                        {disc_only_copies, [node()]}]).
