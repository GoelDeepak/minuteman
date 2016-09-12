-module(minuteman_ct_latency_observer_SUITE).
-include_lib("common_test/include/ct.hrl").
-include_lib("telemetry/include/telemetry.hrl").
-compile(export_all).

all() ->
  [test_init
%  ,test_update_vip_names
  ].

test_init(Config) ->
  Pid = ?config(pid, Config),
  ok = rpc:call(Pid, minuteman_ct_latency_observer_SUITE, run_test_init, [Config]).
run_test_init(_Config) -> ok.

test_update_vip_names(_Config) ->
  #metrics{} = minuteman_ct_latency_observer:update_vip_names(#metrics{}).

init_per_testcase(_, Config) ->
  {ok, Pid} = ct_slave:start(minuteman_ct_latency_observer_SUITE),
  Config1 = rpc:call(Pid, minuteman_ct_latency_observer_SUITE, init_node, [Config]),
  [{pid, Pid} | Config1].

end_per_testcase(Config) ->
  Pid = ?config(pid, Config),
  ok = rpc:call(Pid, minuteman_ct_latency_observer_SUITE, end_node, [Config]),
  ct_slave:stop(Pid).

init_node(Config) ->
  mock_iptables_start(),
  application:ensure_all_started(minuteman),
  Config.

end_node(_Config) ->
  application:stop(minuteman),
  mock_iptables_stop(),
  ok.

mock_iptables_start() ->
  meck:new(iptables, [passthrough, no_link]),
  meck:expect(iptables, check, fun(_Table, _Chain, _Rule) ->
    {ok,[]}
  end),
  meck:expect(iptables, insert, fun(_Table, _Chain, _Rule) ->
    {ok,[]}
  end).

mock_iptables_stop() -> meck:unload(iptables).
