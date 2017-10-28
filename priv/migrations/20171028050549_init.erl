-module('20171028050549_init').
-behavior(db_migration).
-export([up/0, down/0]).

-include_lib("tsoder/include/tables/unique_ids.hrl").
-include_lib("tsoder/include/tables/quote_database.hrl").
-include_lib("tsoder/include/tables/fart_rating.hrl").

up() ->
    mnesia:create_table(unique_ids,
                        [{attributes, record_info(fields, unique_ids)},
                         {disc_only_copies, [node()]}]),
    mnesia:create_table(fart_rating,
                        [{attributes, record_info(fields, fart_rating)},
                         {disc_only_copies, [node()]}]),
    mnesia:create_table(quote,
                        [{attributes, record_info(fields, quote)},
                         {disc_only_copies, [node()]}]).

down() ->
    mnesia:delete_table(unique_ids),
    mnesia:delete_table(fart_rating),
    mnesia:delete_table(quote).
