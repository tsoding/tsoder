-module(tsoder_bot).
-behaviour(gen_server).
-export([start_link/0,
         init/1,
         handle_call/3,
         handle_cast/2,
         terminate/2]).

-record(state, {channel = nothing,
                command_table = #{
                  "hi"   => { fun hi_command/3, "!hi -- says hi to you" },
                  "help" => { fun help_command/3, "!help [command] -- prints the list of supported commands" },
                  "fart" => { fun fart_command/3, "!fart [rating] -- fart" }
                 },
                fart_rating = #{}
               }).

start_link() ->
    gen_server:start_link({local, tsoder_bot}, ?MODULE, [], [{debug, [trace]}]).

init([]) ->
    {ok, #state{}}.

terminate(Reason, State) ->
    error_logger:info_report([{reason, Reason},
                              {state, State}]).

hi_command(State, User, _) ->
    option:foreach(
      fun (Channel) ->
              Channel ! {message, "Hello @" ++ User ++ "!"}
      end,
      State#state.channel).

fart_command(State, User, _) ->
    option:foreach(
      fun (Channel) ->
              Channel ! {message,
                         "@" ++ User ++ ", don't have intestines to perform the operation, sorry."
                        }
      end,
      State#state.channel).

help_command(State, User, "") ->
   option:foreach(
     fun (Channel) ->
             Channel ! {message,
                        "@" ++ User ++ ", supported commands: " ++ string:join(maps:keys(State#state.command_table), ", ")
                       }
     end,
     State#state.channel);
help_command(State, User, Command) ->
    option:foreach(
      fun (Channel) ->
              case State#state.command_table of
                  #{ Command := {_, Description} } ->
                      Channel ! {message,
                                 "@" ++ User ++ ", " ++ Description
                                };
                  _ ->
                      Channel ! {message,
                                 "@" ++ User ++ ", never heard of " ++ Command
                                }
              end
      end,
     State#state.channel).

handle_call(_, _, State) ->
    {reply, unsupported, State}.

handle_cast({message, User, Message}, State) ->
    error_logger:info_report([{message, Message}]),

    option:foreach(
      fun ({Command, Arguments}) ->
              case State#state.command_table of
                  #{ Command := { Action, _ } } ->
                      Action(State, User, Arguments);
                  _ ->
                      error_logger:info_report({unsupported_command,
                                                {Command, Arguments}})
              end
      end,
      user_command:of_string(Message)),

    {noreply, State};
handle_cast({join, Channel}, State) ->
    error_logger:info_report([{join, Channel}]),
    Channel ! {message, "Hello from Tsoder again!"},
    {noreply, State#state{channel = {ok, Channel}}};
handle_cast(Event, State) ->
    error_logger:info_report([{unknown_event, Event}]),
    {noreply, State}.
