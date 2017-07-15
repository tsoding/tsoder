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
    {ok,
     {nothing,
      #{ "hi" =>   { fun hi_command/3, "Says hi to you" },
         "help" => { fun help_command/3, "Prints this help text" } }}}.

terminate(Reason, State) ->
    error_logger:info_report([{reason, Reason},
                              {state, State}]).

hi_command({MaybeChannel, _}, User, _) ->
    option:foreach(
      fun (Channel) ->
              Channel ! {message, "Hello @" ++ User ++ "!"}
      end,
      MaybeChannel).

help_command({MaybeChannel, CommandTable}, User, _) ->
   option:foreach(
     fun (Channel) ->
             Channel ! {message, "@" ++ User ++ ", help command is not ready. Please try again later"}
     end,
     MaybeChannel).

handle_call(_, _, State) ->
    {reply, unsupported, State}.

handle_cast({message, User, Message}, {MaybeChannel, CommandTable}) ->
    error_logger:info_report([{message, Message}]),

    option:foreach(
      fun ({Command, Arguments}) ->
              case CommandTable of
                  #{ Command := { Action, _ } } ->
                      Action({MaybeChannel, Command},
                             User,
                             Arguments);
                  _ ->
                      error_logger:info_report({unsupported_command,
                                                {Command, Arguments}})
              end
      end,
      user_command:of_string(Message)),

    {noreply, {MaybeChannel, CommandTable}};
handle_cast({join, Channel}, {_, CommandTable}) ->
    error_logger:info_report([{join, Channel}]),
    Channel ! {message, "Hello from Tsoder again!"},
    {noreply, {{ok, Channel}, CommandTable}};
handle_cast(Event, State) ->
    error_logger:info_report([{unknown_event, Event}]),
    {noreply, State}.
