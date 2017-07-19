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

log_file_name(Suffix) ->
    string:join(["log_", Suffix, ".txt"], "").

start(_StartType, _StartArgs) ->
    LogFilePath =
        filename:join(
          "./logs",
          log_file_name(
            utc_timestamp:as_string(
              calendar:now_to_universal_time(
                erlang:timestamp())))),
    filelib:ensure_dir(LogFilePath),
    error_logger:logfile({open, LogFilePath}),
    tsoder_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
