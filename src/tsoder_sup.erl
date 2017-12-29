%%%-------------------------------------------------------------------
%% @doc tsoder top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(tsoder_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

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
    {ok, { {one_for_all, 1, 1}, [#{id => tsoder_bot,
                                   start => {tsoder_bot, start_link, []},
                                   restart => permanent,
                                   shutdown => brutal_kill,
                                   type => worker},
                                 %% #{id => irc_transport,
                                 %%   start => {tsoder_irc_transport, start_transport, []},
                                 %%   restart => permanent,
                                 %%   shutdown => brutal_kill,
                                 %%   type => worker},
                                 #{id => russify,
                                   start => {russify, start_link, [[code:priv_dir(tsoder), "/mazarusha/mazarusha.json"]]},
                                   restart => permanent,
                                   shutdown => brutal_kill,
                                   type => worker}]} }.

%%====================================================================
%% Internal functions
%%====================================================================
