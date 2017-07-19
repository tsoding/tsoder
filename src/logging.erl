-module(logging).
-export([utc_timestamp_as_string/1]).

utc_timestamp_as_string({{Year, Month, Day},
                         {Hours, Minutes, Seconds}}) ->
    string:join(
      [string:join(lists:map(fun integer_to_list/1,
                             [Year, Month, Day]),
                   "-"),
       string:join(lists:map(fun integer_to_list/1,
                             [Hours, Minutes, Seconds]),
                   "-")],
      "_").