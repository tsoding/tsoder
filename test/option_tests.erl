-module(option_tests).
-include_lib("eunit/include/eunit.hrl").

map_test() ->
    ?assertMatch({ok, 5},
                 option:map((fun(X) -> X + 1 end),
                            {ok, 4})),
    ?assertMatch({error, "Failed"},
                 option:map((fun(X) -> X + 1 end),
                            {error, "Failed"})).

flat_map_test() ->
    ?assertMatch({ok, 6},
                 option:flat_map((fun(X) ->
                                      {ok, X + 1}
                                  end),
                                 {ok, 5})),
    ?assertMatch({error, "Failed"},
                 option:flat_map((fun(X) ->
                                     X + 1
                                  end),
                                 {error, "Failed"})),
    ?assertMatch({error, "Error"},
                 option:flat_map((fun(X) ->
                                      {error, "Error"}
                                  end),
                                 {ok, 5})).
