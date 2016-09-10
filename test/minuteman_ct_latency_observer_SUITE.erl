-module(minuteman_ct_latency_observer_SUITE).
-include_lib("common_test/include/ct.hrl").
-include_lib("telemetry/include/telemetry.hrl").
-compile(export_all).

all() ->
      [test_init,
       test_update_vip_names].

init_per_testcase(_, Config) ->
  mock_iptables_start(),
  application:ensure_all_started(minuteman),
  Config.

end_per_testcase(_, _Config) ->
  application:stop(minuteman),
  mock_iptables_stop().

test_init(_Config) -> ok.

test_update_vip_names(_Config) ->
  #metrics{} = minuteman_ct_latency_observer:update_vip_names(#metrics{}).

mock_iptables_start() ->
  meck:new(iptables, [passthrough, no_link]),
  meck:expect(iptables, check, fun(_Table, _Chain, _Rule) ->
    {ok,[]}
  end),
  meck:expect(iptables, insert, fun(_Table, _Chain, _Rule) ->
    {ok,[]}
  end).

mock_iptables_stop() -> meck:unload(iptables).
