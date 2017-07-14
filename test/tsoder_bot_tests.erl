-module(tsoder_bot_tests).
-include_lib("eunit/include/eunit.hrl").

join_test_() ->
    {setup,
     fun() -> tsoder_bot:start_link() end,
     fun(_) -> gen_server:stop(tsoder_bot) end,
     fun(_) ->
             [{timeout, 1,
               ?_test(begin
                          gen_server:cast(tsoder_bot, {join, self()}),
                          receive
                              Msg -> ?assertMatch({message, "Hello from Tsoder again!"}, Msg)
                          end
                      end)},
              {timeout, 1,
               ?_test(begin
                          gen_server:cast(tsoder_bot, {message, "!hi"}),
                          receive
                              Msg -> ?assertMatch({message, "Hello there!"}, Msg)
                          end
                      end)},
              {timeout, 1,
               ?_test(begin
                          gen_server:cast(tsoder_bot, {message, "!hi Mark"}),
                          receive
                              Msg -> ?assertMatch({message, "Hello Mark!"}, Msg)
                          end
                      end)}]
     end}.
