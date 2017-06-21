%%%-------------------------------------------------------------------
%% @doc tsoder public API
%% @end
%%%-------------------------------------------------------------------

-module(tsoder_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1, hello_world/0]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    %% TODO(#13): start tsoder_bot instance on application start
    tsoder_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.


hello_world() ->
    Pass = os:getenv("ACCESS_TOKEN"),
    {ok, Sock} = ssl:connect("irc.chat.twitch.tv", 443, [binary, {packet, 0}]),
    ok = ssl:send(Sock, "PASS " ++ Pass ++ "\n"),
    ok = ssl:send(Sock, "NICK tsoding\n"),
    ok = ssl:send(Sock, "JOIN #tsoding\n"),
    ok = ssl:send(Sock, "PRIVMSG #tsoding :hello world\n"),
    ok = ssl:send(Sock, "PRIVMSG #tsoding :all of your bases are belong to us\n"),
    ok = ssl:send(Sock, "PRIVMSG #tsoding :bye\n"),
    ok = ssl:send(Sock, "QUIT\n"),
    ok = ssl:close(Sock).

%%====================================================================
%% Internal functions
%%====================================================================
