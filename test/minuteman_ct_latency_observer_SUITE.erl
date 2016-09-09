-module(minuteman_ct_latency_observer_SUITE).
-include_lib("common_test/include/ct.hrl").
-compile(export_all).

all() ->
      [test_init].

init_per_testcase(_, Config) ->
  mock_iptables(),
  application:ensure_all_started(minuteman),
  Config.

end_per_testcase(_, _Config) ->
  application:stop(minuteman).

test_init(_Config) -> ok.

mock_iptables() ->
  meck:new(iptables, [passthrough, no_link]),
  meck:expect(iptables, check, fun(_Table, _Chain, _Rule) ->
    {ok,[]}
  end),
  meck:expect(iptables, insert, fun(_Table, _Chain, _Rule) ->
    {ok,[]}
  end).

