-module(utc_timestamp_tests).
-include_lib("eunit/include/eunit.hrl").

as_string_test() ->
    ?assertMatch("12-34-56_78-90-12",
                 utc_timestamp:as_string(
                   {{12, 34, 56},
                    {78, 90, 12}})).
