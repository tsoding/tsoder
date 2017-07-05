-module(irc_commands_tests).
-include_lib("eunit/include/eunit.hrl").

of_line_test() ->
    ?assertMatch({ok, {ping, "khooy"}}, irc_command:of_line("PING khooy")).
