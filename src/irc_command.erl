-module(irc_command).
-export([of_line/1]).

regexp_matched_command(Line, RegexpString, Extractor) ->
    {ok, Regexp} = re:compile(RegexpString),
    case re:run(Line, Regexp, [{capture, all, list}]) of
        {match, Groups} ->
            {ok, Extractor(Groups)};
        nomatch ->
            {error, {unsupported_command}}
    end.

ping_command_of_line(Line) ->
    regexp_matched_command(
      Line,
      "PING (.*)",
      fun([_, Host]) -> {ping, Host} end).

privmsg_command_of_line(Line) ->
    regexp_matched_command(
      Line,
      ":.+!(.+)@.+ *PRIVMSG #.+ :(.*)\r\n",
      fun([_, User, Msg]) -> {privmsg, User, Msg} end).

of_line(Line) ->
    Commands = [fun ping_command_of_line/1,
                fun privmsg_command_of_line/1],
    Result = lists:dropwhile(
               fun (Command) -> not option:defined(Command(Line)) end,
               Commands),
    case Result of
        [] ->
            {error, {unsupported_command}};
        [Command|_] ->
            Command(Line)
    end.
