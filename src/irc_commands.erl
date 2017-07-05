-module(irc_commands).
-export([line_as_irc_command/1]).

regexp_matched_command(Line, RegexpString, Extractor) ->
    {ok, Regexp} = re:compile(RegexpString),
    case re:run(Line, Regexp, [{capture, all, list}]) of
        {match, Groups} ->
            {ok, Extractor(Groups)};
        nomatch ->
            {error, {unsupported_command}}
    end.

line_as_ping_command(Line) ->
    regexp_matched_command(
      Line,
      "PING (.*)",
      fun([_, Host]) -> {ping, Host} end).

line_as_privmsg_command(Line) ->
    regexp_matched_command(
      Line,
      ":.+ PRIVMSG #.+ :(.*)$",
      fun([_, Host]) -> {privmsg, Host} end).

line_as_irc_command(Line) ->
    Commands = [fun line_as_ping_command/1,
                fun line_as_privmsg_command/1],
    Result = lists:dropwhile(
               fun (Command) -> not option:defined(Command(Line)) end,
               Commands),
    case Result of
        [] ->
            {error, {unsupported_command}};
        [Command|_] ->
            Command(Line)
    end.
