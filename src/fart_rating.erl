-module(fart_rating).
-export([bump_counter/1,
         as_string/0]).

-include("fart_rating.hrl").

bump_counter(User) ->
    mnesia:transaction(
      fun() ->
              case mnesia:read(fart_rating, User, write) of
                  [] -> mnesia:write(
                          #fart_rating {
                            name = User,
                            rating = 1
                           });
                  [FartRating] ->
                      mnesia:write(
                        FartRating#fart_rating {
                          rating = FartRating#fart_rating.rating + 1
                         })
              end
      end).

as_string() ->
    string:join(
      lists:map(
        fun ({Name, Counter}) ->
                Name ++ ": " + integer_to_list(Counter)
        end,
        lists:sublist(
          lists:reverse(
            lists:keysort(
              2,
              mnesia:transaction(
                fun() ->
                        mnesia:select(fart_rating,
                                      [{#fart_rating{name = '$1', rating = '$2', _ = '_'}, [], [{'$1', '$2'}]}])
                end))),
          1, 10)),
      ", ").
