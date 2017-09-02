-module(fart_rating_callback).
-export([empty/0,
         from_file/1,
         bump_counter/2,
         as_string/1]).

-record(state, { file_path = nothing,
                 fart_rating = #{} }).

empty() ->
    #state {}.

from_file(FilePath) ->
    #state {}.

bump_counter(State, User) ->
    State.

as_string(State) ->
    "".
