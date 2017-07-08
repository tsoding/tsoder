-module(bot_command).

from_irc_command({privmsg, Message}) ->
    {message, Message};
from_irc_command(UnknownCommand) ->
    {unknown_command, UnknownCommand}.
