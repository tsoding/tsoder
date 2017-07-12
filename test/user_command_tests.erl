-module(user_command_tests).
-include_lib("eunit/include/eunit.hrl").

of_string_test() ->
    ?assertMatch(error,
                 user_command:of_string("#$*(&*#32498hjf")),
    ?assertMatch({ok, {"fart", []}},
                 user_command:of_string("!fart")),
    ?assertMatch({ok, {"fart", "something"}},
                 user_command:of_string("!fart something")).

of_privmsg_test() ->
    ?assertMatch(error, user_command:of_privmsg({ping, "sadjkas"})),
    ?assertMatch({ok, {"fart", "something"}},
                 option:flat_map(
                   fun user_command:of_privmsg/1,
                   irc_command:of_line(
                     ":khooy:khooy PRIVMSG #khooy :!fart something\r\n"))).
