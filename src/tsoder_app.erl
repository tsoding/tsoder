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

authorize(Sock, Login, Password) ->
    ok = ssl:send(Sock, "PASS " ++ Password ++ "\n"),
    ok = ssl:send(Sock, "NICK " ++ Login ++ "\n"),
    ok = ssl:send(Sock, "JOIN #tsoding\n").

send_message(Sock, Message) ->
    ok = ssl:send(Sock, "PRIVMSG #tsoding :" ++ Message ++ "\n").

quit(Sock) ->
    ok = ssl:send(Sock, "QUIT\n").

hello_world() ->
    Password = os:getenv("ACCESS_TOKEN"),
    {ok, Sock} = ssl:connect("irc.chat.twitch.tv", 443, [binary, {packet, 0}]),

    authorize(Sock, "tsoding", Password),
    send_message(Sock, "Hello, World"),
    quit(Sock),

    ok = ssl:close(Sock).

%%====================================================================
%% Internal functions
%%====================================================================
