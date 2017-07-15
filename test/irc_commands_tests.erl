-module(irc_commands_tests).
-include_lib("eunit/include/eunit.hrl").

of_line_test() ->
    ?assertMatch({ok, {ping, "khooy"}}, irc_command:of_line("PING khooy")),
    ?assertMatch({ok, {privmsg, "khooy", "Hello, World!"}},
                 irc_command:of_line(":khooy!khooy@khooy PRIVMSG #khooy :Hello, World!\r\n")),
    ?assertMatch({error, {unsupported_command}}, irc_command:of_line("khooy")).
