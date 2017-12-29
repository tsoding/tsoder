-module(custom_commands).
-export([add_command/2,
         del_command/1,
         exec_command/1]).

add_command(Name, Response) ->
    undefined.

del_command(Name) ->
    undefined.

exec_command(Name) ->
    nomessage.
