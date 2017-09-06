-module(logging).
-export([utc_timestamp_as_string/1,
         file_name_from_suffix/1,
         file_path_from_timestamp/1]).

padded_int(P, N) ->
    string:right(integer_to_list(N), P, $0).

utc_timestamp_as_string({{Year, Month, Day},
                         {Hours, Minutes, Seconds}}) ->
    string:join(
      [string:join([integer_to_list(Year),
                    padded_int(2, Month),
                    padded_int(2, Day)],
                   "-"),
       string:join([padded_int(2, Hours),
                    padded_int(2, Minutes),
                    padded_int(2, Seconds)],
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
