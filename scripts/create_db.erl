#!/usr/bin/env escript

-include("../src/fart_rating.hrl").

%% TODO: create_db.erl should always use mnesia dir defined in `./config/sys.config`
%% TODO: implement mnesia schema migrations
main([MnesiaDir]) ->
    application:set_env(mnesia, dir, MnesiaDir),
    ok = mnesia:create_schema([node()]),
    ok = mnesia:start(),
    {atomic, ok} = mnesia:create_table(fart_rating,
                                       [{attributes, record_info(fields, fart_rating)},
                                        {disc_only_copies, [node()]}]).
