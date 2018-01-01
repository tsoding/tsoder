-module(tsoder_bot_tests).
-include_lib("eunit/include/eunit.hrl").

message_test_() ->
    tsoder_bot_fixture(
      [{timeout, 1,
        ?_test(begin
                   ?assertMatch(
                      unsupported,
                      gen_server:call(tsoder_bot, unknown_event))
               end)},
       {timeout, 1,
        ?_test(begin
                   ?assertMatch(
                      nomessage,
                      gen_server:call(
                        tsoder_bot,
                        {message, "khooy", "Just a regular message"}))
               end)}]).

join_test_() ->
    tsoder_bot_fixture(
      [{timeout, 1,
        ?_test(begin
                   ?assertMatch(
                      {message, "I came tsodinNERD"},
                      gen_server:call(tsoder_bot, {join, self()}))
               end)}]).

hi_command_test_() ->
    tsoder_bot_fixture(
      [{timeout, 1,
        ?_test(begin
                   ?assertMatch(
                      {message, "Hello @khooy!"},
                      gen_server:call(tsoder_bot, {message, "khooy", "!hi"}))
               end)}]).

help_command_test_() ->
    tsoder_bot_fixture(
      [{timeout, 1,
        ?_test(begin
                   ?assertMatch(
                        { message,
                          "@khooy, "
                          "supported commands: "
                          "addcom, addquote, delcom, "
                          "fart, help, hi, quote, russify"
                          ". Source code: https://github.com/tsoding/tsoder" },
                      flatten_message(
                        gen_server:call(
                          tsoder_bot,
                          {message, "khooy", "!help"})))
               end)},
       {timeout, 1,
        ?_test(begin
                   ?assertMatch(
                      { message,
                        "@khooy, "
                        "!help [command] -- "
                        "prints the list of supported commands."},
                      flatten_message(
                        gen_server:call(
                          tsoder_bot,
                          {message, "khooy", "!help help"})))
               end)},
       {timeout, 1,
        ?_test(begin
                   ?assertMatch(
                      { message,
                        "@khooy, never heard of khooy" },
                      flatten_message(
                        gen_server:call(
                          tsoder_bot,
                          {message, "khooy", "!help khooy"})))
               end)}]).

%% INTERNAL %%

tsoder_bot_fixture(Test) ->
    {setup,
     fun tsoder_bot:start_link/0,
     fun (_) -> gen_server:stop(tsoder_bot) end,
     Test}.

flatten_message({message, Message}) ->
    {message, lists:flatten(Message)};
flatten_message(X) -> X.
