-module(logging_tests).
-include_lib("eunit/include/eunit.hrl").

utc_timestamp_as_string_test() ->
    ?assertMatch("12-34-56_78-90-12",
                 logging:utc_timestamp_as_string(
                   {{12, 34, 56},
                    {78, 90, 12}})).