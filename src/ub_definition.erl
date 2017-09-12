-module(ub_definition).
-export([from_http_response/1]).

from_http_response({_, _, Body}) ->
    {UbResponse} = jiffy:decode(Body),
    case proplists:get_value(<<"list">>, UbResponse) of
        [{FirstDefinition}|_] -> {ok, binary:bin_to_list(
                                        proplists:get_value(
                                          <<"definition">>,
                                          FirstDefinition))};
        _ -> {not_found}
    end;
from_http_response(_) ->
    {error}.
