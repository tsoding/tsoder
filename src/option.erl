-module(option).
-export([map/2,
         flat_map/2,
         defined/1]).

map(F, {ok, Value}) ->
    {ok, F(Value)};
map(F, None) ->
    None.

flat_map(F, {ok, Value}) ->
    F(Value);
flat_map(F, None) ->
    None.

defined({ok, _}) ->
    true;
defined(_) ->
    false.
