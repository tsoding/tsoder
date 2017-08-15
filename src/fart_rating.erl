-module(fart_rating).
-behaviour(gen_server).

-export([start_link/0,
         start_link/1,
         init/1,
         handle_call/3,
         handle_cast/2,
         terminate/2]).

-record(state, { file_path = nothing,
                 fart_rating = #{} }).

start_link(FilePath) ->
    gen_server:start_link({local, fart_rating}, ?MODULE, [FilePath], []).

start_link() ->
    gen_server:start_link({local, fart_rating}, ?MODULE, [], []).


init([FilePath]) ->
    {ok, #state{ file_path = {ok, FilePath},
                 fart_rating = file_as_fart_rating(FilePath) }};
init([]) ->
    {ok, #state{}}.


terminate(Reason, State) ->
    error_logger:info_report([{reason, Reason},
                              {state, State}]).

handle_call(rating, _, State) ->
    { reply,
      fart_rating_as_string(State#state.fart_rating),
      State }.

handle_cast({fart, User}, State) ->
    { noreply,
      persisted_state(
        bumped_fart_rating_of_user(User, State)) }.

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

bumped_fart_rating_of_user(User, State) ->
    State#state {
      fart_rating = maps:put(User,
                             maps:get(User, State#state.fart_rating, 0) + 1,
                             State#state.fart_rating)
     }.

fart_rating_as_string(Rating) ->
    string:join(
      lists:map(fun ({Name, Counter}) ->
                        Name ++ ": " ++ integer_to_list(Counter)
                end,
        lists:sublist(
          lists:reverse(
            lists:keysort(2,
              maps:to_list(
                Rating))),
          1, 10)),
      ", ").
