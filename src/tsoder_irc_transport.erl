-module(tsoder_irc_transport).
-export([start_transport/0, transport_entry/0]).

start_transport() ->
    {ok, spawn_link(?MODULE, transport_entry, [])}.

%%====================================================================
%% Internal functions
%%====================================================================

remove_newlines(Text) ->
    if
        is_list(Text) -> re:replace(Text, "[\n\r]+", " ", [{return, list}, global]);
        true -> Text
    end.

authorize(Sock, Login, Password, Channel) ->
    ok = ssl:send(Sock, "PASS " ++ Password ++ "\n"),
    ok = ssl:send(Sock, "NICK " ++ Login ++ "\n"),
    ok = ssl:send(Sock, "JOIN #" ++ Channel ++"\n").

send_message(Sock, Message, Channel) ->
    IrcMessage = ["PRIVMSG #", Channel, " :", remove_newlines(Message), "\n"],
    error_logger:info_msg(IrcMessage),
    ok = ssl:send(Sock, IrcMessage).

quit(Sock) ->
    ok = ssl:send(Sock, "QUIT\n").

loop(Sock, Channel) ->
    receive
        {ssl, Sock, Data} ->
            option:foreach(
              fun ({ping, Host}) ->
                      error_logger:info_msg("Received a PING command from ~s PONGing back~n", [Host]),
                      ssl:send(Sock, "PONG " ++ Host ++ "\n");
                  ({privmsg, User, Msg}) ->
                      case gen_server:call(tsoder_bot, {message, User, Msg}, 1000) of
                          {message, Message} -> send_message(Sock, Message, Channel);
                          _ -> nothing
                      end
              end,
              irc_command:of_line(Data)),
            error_logger:info_msg(Data),
            loop(Sock, Channel);
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
    %% TODO(#15): Implement application configuration iso envars
    Channel = os:getenv("TSODER_CHANNEL"),
    Password = os:getenv("ACCESS_TOKEN"),
    {ok, Sock} = ssl:connect("irc.chat.twitch.tv",
                             443,
                             [binary, {packet, 0}]),

    authorize(Sock, "TsoderBot", Password, Channel),
    case gen_server:call(tsoder_bot, {join, self()}, 1000) of
        {message, Message} -> send_message(Sock, Message, Channel);
        _ -> nothing
    end,
    ok = loop(Sock, Channel),
    quit(Sock),

    ok = ssl:close(Sock).
