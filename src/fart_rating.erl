-module(fart_rating).
-behaviour(gen_server).

-export([start_link/1,
         init/1,
         handle_call/3,
         handle_cast/2,
         terminate/2]).

-record(state, { file_name = nothing,
                 fart_rating = #{} }).

start_link(FilePath) ->
    gen_server:start_link({local, fart_rating}, ?MODULE, [FilePath], []).

init([FilePath]) ->
    {ok, #state{ file_name = {ok, FilePath},
                 fart_rating = file_as_fart_rating(FilePath) }}.

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

%% TODO: implement persisted_state
persisted_state(State) ->
    State.

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

%% TODO: implement file_as_fart_rating
file_as_fart_rating(FilePath) ->
    #{}.
