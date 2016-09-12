-module(minuteman_ct_latency_observer_SUITE).
-compile(export_all).
-export([init_node/1]).

-include_lib("common_test/include/ct.hrl").
-include_lib("telemetry/include/telemetry.hrl").

all() ->
  [test_init
  ,test_init
%  ,test_update_vip_names
  ].

test_init(Config) ->
  Node = ?config(node, Config),
  ct:pal("test_init: got Node "),
  ok = rpc:call(Node, minuteman_ct_latency_observer_SUITE, run_test_init, [Config]),
  ct:pal("test_init: rpc call passed").
run_test_init(_Config) -> ok.

test_update_vip_names(_Config) ->
  #metrics{} = minuteman_ct_latency_observer:update_vip_names(#metrics{}).

init_node(Config) ->
  application:ensure_all_started(minuteman),
  {ok, Config}.

end_node(_Config) ->
  application:stop(minuteman),
	ok.

exit_node() -> exit(ok).

kill_node(Node) -> kill_node(Node, net_adm:ping(Node)).
kill_node(Node, pong) ->
	exit(whereis(Node), ok),
	kill_node(Node);
kill_node(_, _) -> ok.

init_per_testcase(_, Config) ->
  {ok, Node} = ct_slave:start(minuteman_ct_latency_observer_SUITE_TEST, [{monitor_master, true}]),
  ct:pal("ct_slave:start returned ~p", [Node]),
  ok = rpc:call(Node, code, add_pathsa, [code:get_path()]),
  {ok, Config1} = rpc:call(Node, minuteman_ct_latency_observer_SUITE, init_node, [Config]),
  ct:pal("rpc call passed ~p", [Config1]),
  [{node, Node} | Config1].

end_per_testcase(_, Config) ->
  Node = ?config(node, Config),
  rpc:call(Node, minuteman_ct_latency_observer_SUITE, end_node, [Config]),
  ct_slave:stop(Node),
	Pid = whereis(Node),
  unlink(Pid),
  exit(Pid, shutdown),
  wait_for_death(Pid).

wait_for_death(Pid) -> wait_for_death(Pid, is_process_alive(Pid)).
wait_for_death(Pid, true) ->
	timer:sleep(10),
	wait_for_death(Pid);
wait_for_death(_, false) -> ok.
