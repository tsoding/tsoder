-module(tsoder_irc_transport).
-export([start_transport/0, transport_entry/0]).

start_transport() ->
    spawn(?MODULE, transport_entry, []).

%%====================================================================
%% Internal functions
%%====================================================================

authorize(Sock, Login, Password) ->
    ok = ssl:send(Sock, "PASS " ++ Password ++ "\n"),
    ok = ssl:send(Sock, "NICK " ++ Login ++ "\n"),
    ok = ssl:send(Sock, "JOIN #tsoding\n").

send_message(Sock, Message) ->
    ok = ssl:send(Sock, "PRIVMSG #tsoding :" ++ Message ++ "\n").

quit(Sock) ->
    ok = ssl:send(Sock, "QUIT\n").

loop(Sock) ->
    receive
        {ssl, Sock, Data} ->
            case irc_commands:line_as_irc_command(Data) of
                {ok, {ping, Host}} ->
                    error_logger:info_msg("Received a PING command from ~w PONGing back~n", [Host]),
                    ssl:send(Sock, "PONG " ++ Host ++ "\n");
                _ ->
                    error_logger:info_msg(Data)
            end,
            loop(Sock);
        {ssl_error, Sock, Reason} ->
            {error, Reason};
        {ssl_closed, Sock} ->
            error_logger:info_msg("Socket ~w closed [~w]~n", [Sock, self()]),
            ok;
        quit ->
            error_logger:info_msg("Quitting by operator request..."),
            ok
    end.

transport_entry() ->
    %% TODO(#15): Implement some application configuration that stores the OAuth token for Twitch authorization
    Password = os:getenv("ACCESS_TOKEN"),
    {ok, Sock} = ssl:connect("irc.chat.twitch.tv",
                             443,
                             [binary, {packet, 0}]),

    authorize(Sock, "tsoding", Password),
    send_message(Sock, "Hello, World"),
    ok = loop(Sock),
    quit(Sock),

    ok = ssl:close(Sock).
