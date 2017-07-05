-module(irc_commands_tests).
-include_lib("eunit/include/eunit.hrl").

line_as_irc_command_test() ->
    ?assertMatch({ok, {ping, "khooy"}}, irc_command:line_as_irc_command("PING khooy")).
