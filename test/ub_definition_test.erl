-module(ub_definition_test).
-include_lib("eunit/include/eunit.hrl").

from_http_response_positive_test() ->
    ?assertMatch({ok, "Khooy"},
                 ub_definition:from_http_response(
                   {status,
                    header,
                    "{\"list\": [{\"definition\": \"Khooy\"},{\"definition\": \"foo\"}]}"})).

from_http_response_negative_test() ->
    ?assertMatch({not_found},
                 ub_definition:from_http_response(
                   {status,
                    header,
                    "{\"list\": []}"})).
