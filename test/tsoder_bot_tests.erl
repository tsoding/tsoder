-module(tsoder_bot_tests).
-include_lib("eunit/include/eunit.hrl").

%% TODO(#50): decompose and rename the join unit test of tsoder_bot
join_test_() ->
    {setup,
     fun() -> tsoder_bot:start_link()
     end,
     fun(_) -> gen_server:stop(tsoder_bot) end,
     fun(_) ->
             [{timeout, 1,
               ?_test(begin
                          ?assertMatch({message, "I came tsodinNERD"},
                                       gen_server:call(tsoder_bot, {join, self()}))
                      end)},
              {timeout, 1,
               ?_test(begin
                          ?assertMatch({message, "Hello @khooy!"},
                                       gen_server:call(tsoder_bot, {message, "khooy", "!hi"}))
                      end)},
              {timeout, 1,
               ?_test(begin
                          ?assertMatch({message, [ "@"
                                                 , "khooy"
                                                 , ", "
                                                 , "supported commands: addquote, fart, help, hi, quote, russify. Source code: https://github.com/tsoding/tsoder"]},
                                       gen_server:call(tsoder_bot, {message, "khooy", "!help"}))
                      end)},
              {timeout, 1,
               ?_test(begin
                          ?assertMatch({message, [ "@"
                                                 , "khooy"
                                                 , ", "
                                                 , "!help [command] -- prints the list of supported commands."]},
                                       gen_server:call(tsoder_bot, {message, "khooy", "!help help"}))
                      end)},
              {timeout, 1,
               ?_test(begin
                          ?assertMatch({message, [ "@"
                                                 , "khooy"
                                                 , ", "
                                                 , "never heard of khooy"]},
                                       gen_server:call(tsoder_bot, {message, "khooy", "!help khooy"}))
                      end)},
              {timeout, 1,
               ?_test(begin
                          ?assertMatch(unsupported,
                                       gen_server:call(tsoder_bot, unknown_event))
                      end)}]
     end}.
