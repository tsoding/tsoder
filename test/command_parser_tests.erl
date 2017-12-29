-module(command_parser_tests).
-include_lib("eunit/include/eunit.hrl").

of_string_test() ->
    ?assertMatch(error,
                 command_parser:from_string("#$*(&*#32498hjf")),
    ?assertMatch({ok, {"fart", []}},
                 command_parser:from_string("!fart")),
    ?assertMatch({ok, {"fart", "something"}},
                 command_parser:from_string("!fart something")),
    ?assertMatch({ok, {"nov2017", []}},
                 command_parser:from_string("!nov2017")),
    ?assertMatch(error,
                 command_parser:from_string("does !fart rating count toward !fart rating")),
    ?assertMatch({ok, {"fart", []}},
                 command_parser:from_string("    !fart")).
