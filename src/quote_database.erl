-module(quote_database).
-export([ add_quote/3
        , random/0
        , quote/1 ]).
-include("quote_database.hrl").

add_quote(Quote, User, Timestamp) ->
    Id = mnesia:dirty_update_counter(unique_ids, quote, 1),
    mnesia:transaction(
      fun () ->
              mnesia:write(
                #quote { id = Id,
                         quote = Quote,
                         user = User,
                         timestamp = Timestamp })
      end),
    Id.

random() ->
    {atomic, Result} =
        mnesia:transaction(
          fun () ->
                  case mnesia:all_keys(quote) of
                      [] -> nothing;
                      Keys -> Key = lists:nth(random:uniform(length(Keys)), Keys),
                              [Quote] = mnesia:read(quote, Key),
                              {ok, Quote}
                  end
          end),
    Result.

quote(Key) ->
    {atomic, Result} =
        mnesia:transaction(
          fun () ->
                  case mnesia:read(quote, Key) of
                      [] -> nothing;
                      [Quote] -> {ok, Quote}
                  end
          end),
    Result.
