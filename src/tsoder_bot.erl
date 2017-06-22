-module(tsoder_bot).
-behaviour(gen_fsm).
-export([start_link/0,
         listen/2,
         init/1,
         terminate/3]).

start_link() ->
    gen_fsm:start_link(?MODULE, listen, [{debug, [trace]}]).

init(State) ->
    {ok, State, {}}.

terminate(Reason, StateName, StateData) ->
    error_logger:info_report([{reason, Reason}]).

listen({message, Message}, {}) ->
    error_logger:info_report([{message, Message}]),
    {next_state, listen, {}};
listen(Event, {}) ->
    error_logger:info_report([{unknown_event, Event}]),
    {next_state, listen, {}}.
