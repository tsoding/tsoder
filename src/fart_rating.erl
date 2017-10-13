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
    {atomic, String} =
        mnesia:transaction(
          fun() ->
                  string:join(
                    lists:map(
                      fun ({Name, Counter}) ->
                              Name ++ ": " ++ integer_to_list(Counter)
                      end,
                      lists:sublist(
                        lists:reverse(
                          lists:keysort(
                            2,
                            lists:map(
                              fun(User) ->
                                      { User#fart_rating.name,
                                        User#fart_rating.rating }
                              end,
                              lists:concat(
                                lists:map(
                                  fun(User) ->
                                          mnesia:read(fart_rating, User, write)
                                  end,
                                  mnesia:all_keys(fart_rating)))))),
                        1, 10)),
                    ", ")
          end),
    String.
