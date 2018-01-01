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
                      { ok,
                        "@khooy, "
                        "supported commands: "
                        "addcom, addquote, delcom, "
                        "fart, help, hi, quote, russify"
                        ". Source code: https://github.com/tsoding/tsoder" },
                      option:map(
                        fun lists:flatten/1,
                        option:custom(
                          message,
                          gen_server:call(
                            tsoder_bot,
                            {message, "khooy", "!help"}))))
               end)},
       {timeout, 1,
        ?_test(begin
                   ?assertMatch(
                      { ok,
                        "@khooy, "
                        "!help [command] -- "
                        "prints the list of supported commands."},
                      option:map(
                        fun lists:flatten/1,
                        option:custom(
                          message,
                          gen_server:call(
                            tsoder_bot,
                            {message, "khooy", "!help help"}))))
               end)},
       {timeout, 1,
        ?_test(begin
                   ?assertMatch(
                      { ok,
                        "@khooy, never heard of khooy" },
                      option:map(
                        fun lists:flatten/1,
                        option:custom(
                          message,
                          gen_server:call(
                            tsoder_bot,
                            {message, "khooy", "!help khooy"}))))
               end)}]).

%% FIXTURES %%

tsoder_bot_fixture(Test) ->
    {setup,
     fun tsoder_bot:start_link/0,
     fun (_) -> gen_server:stop(tsoder_bot) end,
     Test}.
