-module(user_command_tests).
-include_lib("eunit/include/eunit.hrl").

of_string_test() ->
    ?assertMatch(error,
                 user_command:of_string("#$*(&*#32498hjf")),
    ?assertMatch({"fart", []},
                 user_command:of_string("!fart")),
    ?assertMatch({"fart", "something"},
                 user_command:of_string("!fart something")).
