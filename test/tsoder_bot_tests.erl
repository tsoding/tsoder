-module(tsoder_bot_tests).
-include_lib("eunit/include/eunit.hrl").

%% TODO(#50): decompose and rename the join unit test of tsoder_bot
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
                          gen_server:cast(tsoder_bot, {message, "khooy", "!hi"}),
                          receive
                              Msg -> ?assertMatch({message, "Hello @khooy!"}, Msg)
                          end
                      end)},
              {timeout, 1,
               ?_test(begin
                          gen_server:cast(tsoder_bot, {message, "khooy", "!help"}),
                          receive
                              Msg -> ?assertMatch({message, "Hello @khooy!"}, Msg)
                          end
                      end)},
              {timeout, 1,
               ?_test(begin
                          gen_server:cast(tsoder_bot, unknown_event),
                          receive
                              _ ->
                                  erlang:error("Process sent something on incorrect event")
                          after
                              500 ->
                                  ?assert(true)
                          end
                      end)},
              {timeout, 1,
               ?_test(?assertMatch(unsupported,
                                   gen_server:call(tsoder_bot, {message, "!hi"})))}]
     end}.
