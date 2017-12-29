-module(command_parser).
-export([from_string/1]).

from_string(Line) ->
    {ok, Regexp} = re:compile("^\\s*\\!(\\w*)( +(.+))?"),
    case re:run(Line, Regexp, [{capture, all, list}]) of
        {match, [_, CmdName]} -> {ok, {CmdName, []}};
        {match, [_, CmdName, _, CmdArgs]} -> {ok, {CmdName, CmdArgs}};
        nomatch -> error
    end.
