%%%-------------------------------------------------------------------
%% @doc tsoder public API
%% @end
%%%-------------------------------------------------------------------

-module(tsoder_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================


start(_StartType, _StartArgs) ->
    start_logging(),
    ok = migresia:migrate(tsoder),
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
