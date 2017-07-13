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
                 option:flat_map((fun(_) ->
                                      {error, "Error"}
                                  end),
                                 {ok, 5})).

defined_test() ->
    ?assert(option:defined({ok, 5})),
    ?assert(not option:defined(48)).

filter_test() ->
    ?assertMatch({ok, 5},
                 option:filter(fun (X) -> X > 4 end,
                               {ok, 5})),
    ?assertMatch(empty,
                 option:filter(fun (X) -> X < 4 end,
                               {ok, 5})),
    ?assertMatch(fail,
                 option:filter(fun (X) -> X end,
                               fail)).

foreach_test() ->
    InvokedKey = erlang:ref_to_list(make_ref()),
    NotInvokedKey = erlang:ref_to_list(make_ref()),
    ?assertMatch(
       {ok, 5},
       option:foreach(
         fun(X) -> put(InvokedKey, X) end,
         {ok, 5})),
    ?assertMatch(5, get(InvokedKey)),
    ?assertMatch(
       fail,
       option:foreach(
         fun(X) -> put(NotInvokedKey, X) end,
         fail)),
    ?assertMatch(undefined, get(NotInvokedKey)).
