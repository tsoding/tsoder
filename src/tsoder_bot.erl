-module(tsoder_bot).
-behaviour(gen_fsm).
-export([start_link/1,
         listen/2,
         init/1,
         terminate/3]).

start_link(Transport) ->
    gen_fsm:start_link({local, tsoder_bot}, ?MODULE, {listen, Transport}, [{debug, [trace]}]).

init({State, Transport}) ->
    Transport ! ({message, "Hello from Tsoder!"}),
    {ok, State, {Transport}}.

terminate(Reason, StateName, StateData) ->
    error_logger:info_report([{reason, Reason}]).

listen({message, Message}, Data) ->
    error_logger:info_report([{message, Message}]),
    {next_state, listen, Data};
listen(Event, Data) ->
    error_logger:info_report([{unknown_event, Event}]),
    {next_state, listen, Data}.
