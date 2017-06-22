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
    %% TODO(#21): Organize transport-bot pipeline.
    %%
    %% - Supersedes #13
    %%
    %% On application startup create IRC transport instance (see
    %% `tsoding_irc_transport` module) and Tsoder Bot instance (see
    %% `tsoder_bot` module) and organize a pipeline out of them so
    %% 1. The transport receives IRC messages from SSL socket,
    %% 2. The transport forwards the messages to the bot,
    %% 3. The messages that are forwareded to the bot should be transport
    %% agnostic.
    %% 4. The bot logs the received messages.
    tsoder_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
