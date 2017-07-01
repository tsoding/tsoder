-module(irc_commands).
-export([line_as_irc_command/1]).

line_as_irc_command(Line) ->
    {ok, PingRegex} = re:compile("PING (.*)"),
    case re:run(Line, PingRegex, [{capture, all, list}]) of
        {match, [_, Host]} -> {ok, {ping, Host}};
        nomatch -> {error, {unsupported_command}}
    end.
