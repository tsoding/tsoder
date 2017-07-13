-module(user_command).
-export([of_string/1]).

of_string(Line) ->
    {ok, Regexp} = re:compile("\\!(\\w*)( +(.+))?"),
    case re:run(Line, Regexp, [{capture, all, list}]) of
        {match, [_, CmdName]} -> {ok, {CmdName, []}};
        {match, [_, CmdName, _, CmdArgs]} -> {ok, {CmdName, CmdArgs}};
        nomatch -> error
    end.
