-module(user_command_tests).
-include_lib("eunit/include/eunit.hrl").

of_string_test() ->
    ?assertMatch(error,
                 user_command:of_string("#$*(&*#32498hjf")),
    ?assertMatch({ok, {"fart", []}},
                 user_command:of_string("!fart")),
    ?assertMatch({ok, {"fart", "something"}},
                 user_command:of_string("!fart something")),
    ?assertMatch({ok, {"nov2017", []}},
                 user_command:of_string("!nov2017")),
    ?assertMatch(error,
                 user_command:of_string("does !fart rating count toward !fart rating")),
    ?assertMatch({ok, {"fart", []}},
                 user_command:of_string("    !fart")).
