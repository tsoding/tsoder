%%%-------------------------------------------------------------------
%% @doc tsoding_bot public API
%% @end
%%%-------------------------------------------------------------------

-module(tsoding_bot_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    %% TODO: start tsoding_bot_bot instance on application start
    tsoding_bot_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================

hello_world() ->
    io:fwrite("hello, world\n").
