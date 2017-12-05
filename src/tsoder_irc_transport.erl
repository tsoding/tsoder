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

handle_tsoder_bot_reply(nomessage, Sock, Channel) ->
    ok;
handle_tsoder_bot_reply({message, Message}, Sock, Channel) ->
    send_message(Sock, Message, Channel);
handle_tsoder_bot_reply(Reply, _, _) ->
    error_logger:info_report({unknown_tsoder_bot_reply, Reply}).

loop(Sock, Channel) ->
    receive
        {ssl, Sock, Data} ->
            option:foreach(
              fun ({ping, Host}) ->
                      error_logger:info_msg("Received a PING command from ~s PONGing back~n", [Host]),
                      ssl:send(Sock, "PONG " ++ Host ++ "\n");
                  ({privmsg, User, Msg}) ->
                      handle_tsoder_bot_reply(
                        gen_server:call(tsoder_bot, {message, User, Msg}, 1000),
                        Sock,
                        Channel)
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
            ok;
        Msg ->
            error_logger:info_report({unknown_message, Msg}),
            loop(Sock, Channel)
    end.

transport_entry() ->
    %% TODO(#15): Implement application configuration iso envars
    Channel = os:getenv("TSODER_CHANNEL"),
    Password = os:getenv("ACCESS_TOKEN"),
    {ok, Sock} = ssl:connect("irc.chat.twitch.tv",
                             443,
                             [binary, {packet, 0}]),

    authorize(Sock, "TsoderBot", Password, Channel),
    handle_tsoder_bot_reply(
      gen_server:call(tsoder_bot, {join, self()}, 1000),
      Sock,
      Channel),
    ok = loop(Sock, Channel),
    quit(Sock),

    ok = ssl:close(Sock).
