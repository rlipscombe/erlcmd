-module(cmd).
-export([run/1]).

run(Cmd) ->
    run(Cmd, 5000).

run(Cmd, Timeout) ->
    Port = erlang:open_port({spawn, Cmd}, [exit_status]),
    loop(Port, [], Timeout).

loop(Port, Data, Timeout) ->
    receive
        {Port, {data, NewData}} ->
            loop(Port, Data ++ NewData, Timeout);
        {Port, {exit_status, 0}} ->
            {ok, Data};
        {Port, {exit_status, S}} ->
            {error, {exit_status, S}}
    after Timeout ->
            {error, timeout}
    end.

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

stdout_test() ->
    {ok, "Hello World\n"} = run("echo Hello World").

timeout_test() ->
    {error, timeout} = run("sleep 10", 20).

exit_status_test() ->
    {error, {exit_status, 1}} = run("false").

-endif.
