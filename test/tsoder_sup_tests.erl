-module(tsoder_sup_tests).
-include_lib("eunit/include/eunit.hrl").

failing_to_fail_test() -> ?assertMatch({ok, "PING", "google.com", "Test"}, tsoder_sup:parse_ping_message("Test")).
