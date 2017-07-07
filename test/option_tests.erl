-module(option_tests).
-include_lib("eunit/include/eunit.hrl").

map_test() ->
    ?assertMatch({ok, 5},
                 option:map((fun(X) -> X + 1 end),
                            {ok, 4})),
    ?assertMatch({error, "Failed"},
                 option:map((fun(X) -> X + 1 end),
                            {error, "Failed"})).
