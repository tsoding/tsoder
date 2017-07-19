-module(logging).
-export([utc_timestamp_as_string/1,
         file_name_from_suffix/1,
         file_path_from_timestamp/1]).

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

file_name_from_suffix(Suffix) ->
    string:join(["log_", Suffix, ".txt"], "").

file_path_from_timestamp(Timestamp) ->
    filename:join(
      "./logs",
      file_name_from_suffix(
        utc_timestamp_as_string(
          calendar:now_to_universal_time(
            Timestamp)))).
