%%%-------------------------------------------------------------------
%% @doc tsoder public API
%% @end
%%%-------------------------------------------------------------------

-module(tsoder_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-include("fart_rating.hrl").

%%====================================================================
%% API
%%====================================================================


start(_StartType, _StartArgs) ->
    start_logging(),
    start_mnesia(),
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
    error_logger:logfile({open, LogFilePath}),
    error_logger:tty(false).

start_mnesia() ->
    mnesia:create_schema([node()]),
    mnesia:create_table(fart_rating,
                        [{attributes, record_info(fields, fart_rating)}]).
