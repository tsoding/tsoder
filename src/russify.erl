-module(russify).
-behaviour(gen_server).
-export([start_link/1,
         init/1,
         handle_call/3,
         handle_cast/2,
         terminate/2]).

-record(state, { mazarusha }).

start_link(MazarushaFile) ->
    gen_server:start_link({local, russify}, ?MODULE, [MazarushaFile], []).


init([MazarushaFile]) ->
    {ok, MazarushaData} = file:read_file(MazarushaFile),
    {Mazarusha} = jiffy:decode(MazarushaData),
    {ok, #state{ mazarusha = Mazarusha }}.

terminate(Reason, State) ->
    error_logger:info_report([{reason, Reason},
                              {state, State}]).

handle_call(Data, _, State) ->
    {reply, russify(Data, State#state.mazarusha), State}.

handle_cast(_, State) ->
    {noreply, State}.

russify(Data, Mazarusha) ->
    binary:list_to_bin(
      lists:flatmap(
        fun(Key) ->
                case proplists:get_value(<<Key>>, Mazarusha) of
                    undefined -> [Key];
                    Value -> binary:bin_to_list(Value)
                end
        end,
        binary:bin_to_list(Data))).
