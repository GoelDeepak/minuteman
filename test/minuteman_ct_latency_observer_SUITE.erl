-module(minuteman_ct_latency_observer_SUITE).
-include_lib("common_test/include/ct.hrl").
-compile(export_all).

all() ->
      [test_init].

init_per_testcase(_, Config) ->
	{ok, Pid} = minuteman_ct_latency_observer:start_link(),
	[{pid, Pid} | Config].

end_per_testcase(_, Config) ->
  Pid = ?config(pid, Config),
  unlink(Pid),
  exit(Pid, shutdown),
  wait_for_death(Pid).

wait_for_death(Pid) -> wait_for_death(Pid, is_process_alive(Pid)).

wait_for_death(Pid, true) ->
      timer:sleep(10),
      wait_for_death(Pid);
wait_for_death(Pid, false) -> ok.

test_init(Config) ->
  Pid = ?config(pid, Config).
