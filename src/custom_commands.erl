-module(custom_commands).
-export([add_command/2,
         del_command/1,
         exec_command/2]).
-include("custom_commands.hrl").

add_command(Name, Response) ->
    undefined.

del_command(Name) ->
    undefined.

exec_command(Name, Mention) ->
    {atomic, Result} =
        mnesia:transaction(
          fun() ->
                  case { mnesia:read(custom_command, Name), Mention } of
                      {[Command], []} -> {message, Command#custom_command.response};
                      {[Command], Mention} -> {message, [ "@"
                                                        , Mention
                                                        , ", "
                                                        , Command#custom_command.response]};
                      _ -> nomessage
                  end
          end),
    Result.
