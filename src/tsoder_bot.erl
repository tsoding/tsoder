-module(tsoder_bot).
-behaviour(gen_server).
-export([start_link/0,
         init/1,
         handle_call/3,
         handle_cast/2,
         terminate/2]).

-record(state, {channel = nothing,
                %% TODO(#66): persist fart rating
                fart_rating = #{}
               }).

start_link() ->
    gen_server:start_link({local, tsoder_bot}, ?MODULE, [], [{debug, [trace]}]).

init([]) ->
    {ok, #state{}}.

terminate(Reason, State) ->
    error_logger:info_report([{reason, Reason},
                              {state, State}]).

handle_call(_, _, State) ->
    {reply, unsupported, State}.

handle_cast({message, User, Message}, State) ->
    error_logger:info_report([{message, Message}]),

    {noreply,
     option:default(State,
       option:map(
         fun ({Command, Arguments}) ->
                 case command_table() of
                     #{ Command := { Action, _ } } ->
                         Action(State, User, Arguments);
                     _ ->
                         error_logger:info_report({unsupported_command,
                                                   {Command, Arguments}}),
                         State
                 end
         end,
         user_command:of_string(Message)))
    };
handle_cast({join, Channel}, State) ->
    error_logger:info_report([{join, Channel}]),
    Channel ! {message, "Hello from Tsoder again!"},
    {noreply, State#state{channel = {ok, Channel}}};
handle_cast(Event, State) ->
    error_logger:info_report([{unknown_event, Event}]),
    {noreply, State}.

%% Internal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

command_table() ->
    #{
       "hi"   => { fun hi_command/3, "!hi -- says hi to you" },
       "help" => { fun help_command/3, "!help [command] -- prints the list of supported commands. Source code: https://github.com/tsoding/tsoder" },
       "fart" => { fun fart_command/3, "!fart [rating] -- fart" }
     }.

hi_command(State, User, _) ->
    option:foreach(
      fun (Channel) ->
              Channel ! {message, "Hello @" ++ User ++ "!"}
      end,
      State#state.channel),
    State.

fart_command(State, User, "rating") ->
    option:foreach(
      fun (Channel) ->
              Channel ! string_as_user_response(
                          User,
                          fart_rating_as_string(State))
      end,
      State#state.channel),
    State;
fart_command(State, User, _) ->
    option:default(State,
      option:map(
        fun (Channel) ->
                Channel ! string_as_user_response(User,
                                                  "don't have intestines to perform the operation, sorry."),
                bumped_fart_rating_of_user(User, State)
        end,
        State#state.channel)).

help_command(State, User, "") ->
   option:foreach(
     fun (Channel) ->
             Channel ! string_as_user_response(User,
                                               "supported commands: "
                                               ++ string:join(maps:keys(command_table()), ", "))
     end,
     State#state.channel),
    State;
help_command(State, User, Command) ->
    option:foreach(
      fun (Channel) ->
              case command_table() of
                  #{ Command := {_, Description} } ->
                      Channel ! string_as_user_response(User, Description);
                  _ ->
                      Channel ! string_as_user_response(User, "never heard of " ++ Command)
              end
      end,
     State#state.channel),
    State.

string_as_user_response(User, String) ->
    {message, "@" ++ User ++ ", " ++ String}.

fart_rating_as_string(State) ->
    string:join(
      lists:map(fun ({Name, Counter}) -> Name ++ ": " ++ integer_to_list(Counter) end,
        lists:sublist(
          lists:reverse(
            lists:keysort(2,
              maps:to_list(
                State#state.fart_rating))),
          1, 10)),
      ", ").

bumped_fart_rating_of_user(User, State) ->
    State#state {
      fart_rating = maps:put(User,
                             maps:get(User, State#state.fart_rating, 0) + 1,
                             State#state.fart_rating)
     }.
