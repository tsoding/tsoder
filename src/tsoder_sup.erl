%%%-------------------------------------------------------------------
%% @doc tsoder top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(tsoder_sup).

-behaviour(supervisor).

%% API
-export([start_link/0, parse_ping_message/1]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    {ok, { {one_for_all, 0, 1}, []} }.

%%====================================================================
%% Internal functions
%%====================================================================

parse_ping_message(Line) ->
    {ok, "PING", "google.com", Line}.