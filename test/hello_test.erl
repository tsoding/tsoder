-module(hello_test).
-include_lib("eunit/include/eunit.hrl").

failing_to_fail_test() -> ?assert(true).
