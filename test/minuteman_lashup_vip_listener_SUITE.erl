-module(minuteman_lashup_vip_listener_SUITE).
-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include_lib("telemetry/include/telemetry.hrl").

all() ->
  [test_init
  ,test_update_vip_names1
  ,test_update_vip_names2
	,test_update_vip_names3
  ].

test_init(_Config) -> ok.

test_update_vip_names1(_Config) ->
  #metrics{} = minuteman_lashup_vip_listener:update_vip_names(#metrics{}),
  ok.

test_update_vip_names2(_Config) ->
  T = sets:from_list([1,2,3]),
  #metrics{dirty_histos = T} = minuteman_lashup_vip_listener:update_vip_names(#metrics{dirty_histos = T}),
  ok.

test_update_vip_names3(_Config) ->
  A = orddict:from_list([{a,1},{b,2}]),
  B = orddict:from_list([{a,1},{b,2},{c,3}]),
  C = sets:from_list([1,2,3]),
  D = sets:from_list([1,2,3,4]),
	M = #metrics{time_to_histos = A, time_to_counters = B, dirty_histos = C,  dirty_counters = D},
  M = minuteman_lashup_vip_listener:update_vip_names(M),
	ok.

init_per_testcase(_, Config) ->
  {ok, _} = application:ensure_all_started(minuteman),
  Config.

end_per_testcase(_, _Config) -> 
  ok = application:stop(minuteman).
