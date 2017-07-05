-module(irc_commands).
-export([line_as_irc_command/1]).

line_as_irc_command(Line) ->
    {ok, PingRegex} = re:compile("PING (.*)"),
    {ok, PrivmsgRegex} = re:compile(":.+ PRIVMSG #.+ :(.*)$"),
    case re:run(Line, PingRegex, [{capture, all, list}]) of
        {match, [_, Host]} -> {ok, {ping, Host}};
        nomatch -> case re:run(Line, PrivmsgRegex, [{capture, all, list}]) of
                       {match, [_, Msg]} -> {ok, {privmsg, Msg}};
                       nomatch -> {error, {unsupported_command}}
                   end
    end.
