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

init_per_testcase(_, Config) ->
  % BUG, https://github.com/erlang/otp/pull/1095, should be {ok, Node}
  {error, started_not_connected, Node} = ct_slave:start(minuteman_ct_latency_observer_SUITE_TEST, []),
  ct:pal("ct_slave:start passed"),
  ok = rpc:call(Node, code, add_pathsa, [code:get_path()]),
  {ok, Config1} = rpc:call(Node, minuteman_ct_latency_observer_SUITE, init_node, [Config]),
  ct:pal("rpc call passed ~p", [Config1]),
  [{node, Node} | Config1].

end_per_testcase(Config) ->
  Node = ?config(node, Config),
  ok = rpc:call(Node, minuteman_ct_latency_observer_SUITE, end_node, [Config]),
  ct_slave:stop(Node),
  wait_for_death(Node).

init_node(Config) ->
  %mock_iptables_start(),
  application:ensure_all_started(minuteman),
  {ok, Config}.

end_node(_Config) ->
  application:stop(minuteman),
  %mock_iptables_stop(),
  exit(ok).

%mock_iptables_start() ->
%  meck:new(iptables, [passthrough, no_link]),
%  meck:expect(iptables, check, fun(_Table, _Chain, _Rule) ->
%    {ok,[]}
%  end),
%  meck:expect(iptables, insert, fun(_Table, _Chain, _Rule) ->
%    {ok,[]}
%  end).

%mock_iptables_stop() -> meck:unload(iptables).

wait_for_death(Pid) -> wait_for_death(Pid, is_process_alive(Pid)).

wait_for_death(Pid, true) ->
  timer:sleep(10),
  wait_for_death(Pid);
wait_for_death(_, false) -> ok.

