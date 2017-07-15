-module(tsoder_bot).
-behaviour(gen_server).
-export([start_link/0,
         init/1,
         handle_call/3,
         handle_cast/2,
         terminate/2]).

start_link() ->
    gen_server:start_link({local, tsoder_bot}, ?MODULE, [], [{debug, [trace]}]).

init([]) ->
    {ok, {}}.

terminate(Reason, State) ->
    error_logger:info_report([{reason, Reason},
                              {state, State}]).

handle_call(_, _, State) ->
    {reply, unsupported, State}.

handle_cast({message, User, Message}, Channel) ->
    error_logger:info_report([{message, Message}]),

    option:foreach(
      fun (_) ->
              error_logger:info_report({command, hi, User}),
              Channel ! {message, "Hello " ++ User ++ "!"}
      end,
      option:filter(
        fun ({Cmd, _}) -> Cmd == "hi" end,
        user_command:of_string(Message))),

    {noreply, Channel};
handle_cast({join, Channel}, _) ->
    error_logger:info_report([{join, Channel}]),
    Channel ! {message, "Hello from Tsoder again!"},
    {noreply, Channel};
handle_cast(Event, Channel) ->
    error_logger:info_report([{unknown_event, Event}]),
    {noreply, Channel}.
