%%%-------------------------------------------------------------------
%% @doc tsoder public API
%% @end
%%%-------------------------------------------------------------------

-module(tsoder_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-include("fart_rating.hrl").
-include("quote_database.hrl").
-include("unique_ids.hrl").

%%====================================================================
%% API
%%====================================================================


start(_StartType, _StartArgs) ->
    start_logging(),
    memigrate:migrate(migrations()),
    ok = mnesia:wait_for_tables([ unique_ids
                                , fart_rating
                                , quote
                                ],
                                5000),
    tsoder_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================

start_logging() ->
    LogFilePath =
        logging:file_path_from_timestamp(erlang:timestamp()),
    filelib:ensure_dir(LogFilePath),
    error_logger:logfile({open, LogFilePath}).

migrations() ->
    [{1, fun() ->
                 mnesia:create_table(unique_ids,
                                     [{attributes, record_info(fields, unique_ids)},
                                      {disc_only_copies, [node()]}]),
                 mnesia:create_table(fart_rating,
                                     [{attributes, record_info(fields, fart_rating)},
                                      {disc_only_copies, [node()]}]),
                 mnesia:create_table(quote,
                                     [{attributes, record_info(fields, quote)},
                                      {disc_only_copies, [node()]}]),
                 ok
         end}].
