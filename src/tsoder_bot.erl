-module(tsoder_bot).
-behaviour(gen_server).
-export([start_link/0,
         init/1,
         handle_call/3,
         handle_cast/2,
         terminate/2]).

-record(state, { channel = nothing }).

-include("fart_rating.hrl").
-include("quote_database.hrl").

start_link() ->
    gen_server:start_link({local, tsoder_bot}, ?MODULE, [], []).

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
       "hi"   => { fun hi_command/3, "!hi -- says hi to you" }
     , "help" => { fun help_command/3, "!help [command] -- prints the list of supported commands." }
     , "fart" => { fun fart_command/3, "!fart [rating] -- fart" }
     , "addquote" => { fun addquote_command/3, "!addquote <quote> -- add a quote to the quote database" }
     , "quote" => { fun quote_command/3, "!quote [id] -- select a quote from the quote database" }
     , "russify" => { fun russify_command/3, "!russify <western-spy-text> -- russify western spy text" }
       %% TODO(#114): Implement custom response command system
       %%
       %% - `!addcommand <command-name> <text>`
       %% - `!removecommand <command-name>`
       %%
       %% Custom command should have the following signature:
       %% `!command-name [user]`. Where `[user]` is an optional user
       %% to mention before the `<text>`. If the user is not provided
       %% the `<text>` is just sent to the chat w/o mentioning
       %% anybody/
       %%
       %% This command system should replace hardcoded temporary
       %% commands like !nov2017
     %% TODO(#115): Design a more advanced mechanism for disabling/enabling commands
     %% , "ub"   => { fun ub_command/3, "!ub [term] -- Lookup the term in Urban Dictionary" }
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
              %% TODO(#98): response should include the link to the defintion page
              Channel ! string_as_user_response(
                          User,
                          option:default(
                            "Could not find the term",
                            option:map(
                              fun (Definition) ->
                                      string:substr(Definition, 1, 200)
                              end,
                              option:flat_map(
                                fun ub_definition:from_http_response/1,
                                httpc:request(
                                  "http://api.urbandictionary.com/v0/define?term="
                                  ++ http_uri:encode(Term))))))
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
                          fart_rating:as_string())
      end,
      State#state.channel),
    State;
fart_command(State, User, _) ->
    option:foreach(
      fun (Channel) ->
              Channel ! string_as_user_response(User,
                                                "don't have intestines to perform the operation."),
              fart_rating:bump_counter(User)
      end,
      State#state.channel),
    State.

addquote_command(State, User, "") ->
    option:foreach(
      fun (Channel) ->
              Channel ! string_as_user_response(User, "Empty quotes are ignored")
      end,
      State#state.channel),
    State;
addquote_command(State, User, Quote) ->
    option:foreach(
      fun (Channel) ->
              %% TODO(#109): design a more advanced authentication system for commands
              Authorized = lists:member(User, ["tsoding", "r3x1m", "bpaf"]),
              if
                  Authorized ->
                      Id = quote_database:add_quote(Quote, User, erlang:timestamp()),
                      Channel ! string_as_user_response(User, "Added the quote under number " ++ integer_to_list(Id));
                  true ->
                      Channel ! string_as_user_response(User, "Nope")
              end
      end,
      State#state.channel),
    State.

quote_command(State, User, []) ->
    option:foreach(
      fun (Channel) ->
              option:foreach(
                fun (Quote) ->
                        Channel ! string_as_user_response(User,
                                                          Quote#quote.quote
                                                          ++ " ("
                                                          ++ integer_to_list(Quote#quote.id)
                                                          ++ ")")
                end,
                quote_database:random())
      end,
      State#state.channel),
    State;
quote_command(State, User, Id) ->
    option:foreach(
      fun (Channel) ->
              option:foreach(
               fun (Quote) ->
                       Channel ! string_as_user_response(User,
                                                          Quote#quote.quote
                                                          ++ " ("
                                                          ++ integer_to_list(Quote#quote.id)
                                                          ++ ")")
               end,
               quote_database:quote(Id))
      end,
      State#state.channel),
    State.


russify_command(State, User, Text) ->
    option:foreach(
     fun(Channel) ->
             Channel ! string_as_user_response(User,
                                               gen_server:call(russify, binary:list_to_bin(Text)))
     end,
      State#state.channel),
    State.

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
    {message, ["@", User, ", ", String]}.
