-module(tsoder_bot).
-behaviour(gen_server).
-export([start_link/2,
         init/1,
         handle_call/3,
         handle_cast/2,
         terminate/2]).

-record(state, { channel = nothing,
                 fart_rating_module,
                 fart_rating_state }).

start_link(FartRatingState, FartRatingModule) ->
    gen_server:start_link({local, tsoder_bot}, ?MODULE, [FartRatingState, FartRatingModule], []).

init([FartRatingState, FartRatingModule]) ->
    {ok, #state{ fart_rating_module = FartRatingModule,
                 fart_rating_state = FartRatingState() }}.

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
       "help" => { fun help_command/3, "!help [command] -- prints the list of supported commands." },
       "fart" => { fun fart_command/3, "!fart [rating] -- fart" },
       "ub"   => { fun ub_command/3, "!ub [term] -- Lookup the term in Urban Dictionary" }
     }.

ub_command(State, User, "") ->
    option:foreach(
      fun (Channel) ->
              Channel ! string_as_user_response(User, "Cannot lookup an empty term")
      end,
      State#state.channel),
    State;
ub_command(State, User, Term) ->
    option:foreach(
      fun(Channel) ->
              %% TODO: response should include the link to the defintion page
              Channel ! string_as_user_response(
                          User,
                          option:default(
                            "Could not find the term",
                            option:flat_map(
                              fun ub_definition:from_http_response/1,
                              httpc:request(
                                "http://api.urbandictionary.com/v0/define?term="
                                ++ http_uri:encode(Term)))))
      end,
      State#state.channel),
    State.


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
                          apply(State#state.fart_rating_module,
                                as_string,
                                [State#state.fart_rating_state]))
      end,
      State#state.channel),
    State;
fart_command(State, User, _) ->
    option:default(
      State,
      option:map(
        fun (Channel) ->
                Channel ! string_as_user_response(User,
                                                  "don't have intestines to perform the operation, sorry."),
                State#state { fart_rating_state =
                                  apply(State#state.fart_rating_module,
                                        bump_counter,
                                        [State#state.fart_rating_state, User]) }
        end,
        State#state.channel)).

help_command(State, User, "") ->
   option:foreach(
     fun (Channel) ->
             Channel ! string_as_user_response(User,
                                               "supported commands: "
                                               ++ string:join(maps:keys(command_table()), ", ")
                                               ++ ". Source code: https://github.com/tsoding/tsoder")
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
