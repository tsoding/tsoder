-module(option).
-export([map/2,
         flat_map/2,
         defined/1,
         filter/2,
         foreach/2]).

map(F, {ok, Value}) ->
    {ok, F(Value)};
map(_, None) ->
    None.

flat_map(F, {ok, Value}) ->
    F(Value);
flat_map(_, None) ->
    None.

defined({ok, _}) ->
    true;
defined(_) ->
    false.

filter(P, {ok, Value}) ->
    case P(Value) of
        true -> {ok, Value};
        _ -> {error, "Didn't satisfy the predicate"}
    end;
filter(_, None) -> None.

foreach(F, {ok, Value}) ->
    F(Value),
    {ok, Value};
foreach(_, None) ->
    None.
