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
    #state{ file_path = {ok, FilePath},
            fart_rating = file_as_fart_rating(FilePath) }.

bump_counter(State, User) ->
    persisted_state(
      State#state {
        fart_rating = maps:put(User,
                               maps:get(User, State#state.fart_rating, 0) + 1,
                               State#state.fart_rating)
       }).

as_string(State) ->
    string:join(
      lists:map(fun ({Name, Counter}) ->
                        Name ++ ": " ++ integer_to_list(Counter)
                end,
        lists:sublist(
          lists:reverse(
            lists:keysort(2,
              maps:to_list(
                State#state.fart_rating))),
          1, 10)),
      ", ").

%% Internal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

with_dets_file(FilePath, F) ->
    {ok, Ref} = dets:open_file(FilePath, [{type, set}]),
    Result = F(Ref),
    dets:close(Ref),
    Result.

persisted_state(State) ->
    option:foreach(
      fun(FilePath) ->
              with_dets_file(
                FilePath,
                fun(Ref) ->
                        dets:insert(
                          Ref,
                          { fart_rating,
                            State#state.fart_rating })
                end)
      end,
      State#state.file_path),
    State.

file_as_fart_rating(FilePath) ->
    with_dets_file(
      FilePath,
      fun(Ref) ->
              case dets:lookup(Ref, fart_rating) of
                  [] -> #{};
                  [{fart_rating, FartRating}] -> FartRating
              end
      end).
