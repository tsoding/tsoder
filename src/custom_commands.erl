-module(custom_commands).
-export([add_command/2,
         del_command/1,
         exec_command/2]).
-include("custom_commands.hrl").

add_command(Name, Response) ->
    {atomic, Result} =
        mnesia:transaction(
         fun () ->
                 case mnesia:read(custom_command, Name) of
                     [_] -> ok = mnesia:write(#custom_command { name = Name
                                                              , response = Response }),
                            updated;
                     [] -> mnesia:write(#custom_command { name = Name
                                                        , response = Response })
                 end
         end),
    Result.

del_command(Name) ->
    {atomic, Result} =
        mnesia:transaction(
         fun () ->
                 case mnesia:read(custom_command, Name) of
                     [_] -> mnesia:delete({custom_command, Name});
                     [] -> noexists
                 end
         end),
    Result.

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
