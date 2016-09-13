-module(minuteman_ct_latency_observer_SUITE).
-compile(export_all).
-export([init_node/1]).


-include_lib("common_test/include/ct.hrl").
-include_lib("telemetry/include/telemetry.hrl").


all() ->
  [test_init
  %,test_init
  %,test_update_vip_names
  ].


test_init(Config) ->
  Node = ?config(node, Config),
  ok = rpc:call(Node, minuteman_ct_latency_observer_SUITE, run_test_init, [Config]).

run_test_init(_Config) -> ok.


test_update_vip_names(Config) ->
  Node = ?config(node, Config),
  ok = rpc:call(Node, minuteman_ct_latency_observer_SUITE, run_test_update_vip_names, [Config]).

run_test_update_vip_names(_Config) ->
  #metrics{} = minuteman_ct_latency_observer:update_vip_names(#metrics{}),
  ok.


init_node(Config) ->
  ok = mock_iptables_start(),
  {ok, _} = application:ensure_all_started(minuteman),
  {ok, Config}.

end_node(_Config) -> 
  ok = application:stop(minuteman),
  ok = mock_iptables_stop().


mock_iptables_start() ->
  ok = meck:new(iptables, [passthrough, no_link]),
  ok =  meck:expect(iptables, check, fun(_Table, _Chain, _Rule) ->
    {ok,[]}
  end),
  ok = meck:expect(iptables, insert, fun(_Table, _Chain, _Rule) ->
    {ok,[]}
  end).

mock_iptables_stop() -> meck:unload(iptables).


init_per_testcase(_, Config) ->
  Name = minuteman_ct_latency_observer_SUITE_TEST,
  {ok, Node} = ct_slave:start(Name, [{monitor_master, true}]),
  ct:pal("ct_slave:start returned ~p", [Node]),
  ok = rpc:call(Node, code, add_pathsa, [code:get_path()]),
  {ok, Config1} = rpc:call(Node, minuteman_ct_latency_observer_SUITE, init_node,
                           [Config]),
  ct:pal("rpc call passed ~p", [Config1]),
  ct:pal("init_per_testcase done!!!"),
  [{name, Name} , {node, Node} | Config1].


end_per_testcase(_, Config) ->
  Node = ?config(node, Config),
  Name = ?config(name, Config),
  ok = rpc:call(Node, minuteman_ct_latency_observer_SUITE, end_node, [Config]),
  {ok, Node} = ct_slave:stop(Name),
  ct:pal("end_per_testcase done!!!").

