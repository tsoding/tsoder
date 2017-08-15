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
    {reply, fart_rating_as_string(State#state.fart_rating), State}.

handle_cast({fart, User}, State) ->
    { noreply,
      persisted_state(
        bumped_fart_rating_of_user(User, State)) }.

%% Internal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% TODO: implement persisted_state
persisted_state(State) ->
    State.

%% TODO: implemented bumped_fart_rating_of_user
bumped_fart_rating_of_user(User, State) ->
    State.

%% TODO: implement fart_rating_as_string
fart_rating_as_string(Rating) ->
    "Fart Rating".

%% TODO: implement file_as_fart_rating
file_as_fart_rating(FilePath) ->
    #{}.
