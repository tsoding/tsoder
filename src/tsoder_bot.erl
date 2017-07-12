-module(tsoder_bot).
-behaviour(gen_fsm).
-export([start_link/0,
         listen/2,
         init/1,
         terminate/3]).

start_link() ->
    gen_fsm:start_link({local, tsoder_bot}, ?MODULE, listen, [{debug, [trace]}]).

init(State) ->
    {ok, State, {}}.

terminate(Reason, StateName, StateData) ->
    error_logger:info_report([{reason, Reason}]).

listen({message, Message}, Channel) ->
    error_logger:info_report([{message, Message}]),

    option:foreach(
      fun ({_, []}) -> Channel ! {message, "Hello there!"};
          ({_, Name}) -> Channel ! {message, "Hello " ++ Name ++ "!"}
      end,
      option:filter(
        fun ({Cmd, _}) -> Cmd == "hi" end,
        user_command:of_string(Message))),

    {next_state, listen, Channel};
listen({join, Channel}, Data) ->
    error_logger:info_report([{join, Channel}]),
    Channel ! {message, "Hello from Tsoder again!"},
    {next_state, listen, Channel};
listen(Event, Data) ->
    error_logger:info_report([{unknown_event, Event}]),
    {next_state, listen, Data}.
