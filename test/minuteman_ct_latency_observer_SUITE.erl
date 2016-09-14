-module(minuteman_ct_latency_observer_SUITE).
-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include_lib("telemetry/include/telemetry.hrl").

all() ->
  [test_init
  ,test_update_vip_names1
  ,test_update_vip_names2
  ].

test_init(_Config) -> ok.

test_update_vip_names1(_Config) ->
  #metrics{} = minuteman_ct_latency_observer:update_vip_names(#metrics{}),
  ok.

test_update_vip_names2(_Config) ->
  T = sets:from_list([1,2,3]),
  #metrics{dirty_histos = T} = minuteman_ct_latency_observer:update_vip_names(#metrics{dirty_histos = T}),
  ok.


init_per_testcase(_, Config) ->
  {ok, _} = application:ensure_all_started(minuteman),
  Config.

end_per_testcase(_, _Config) -> 
  Queue = application:get_env(minuteman, queue, 50),
  ct:pal("queue ~p", [Queue]),
  application:set_env(minuteman, queue, Queue + 10),
  ok = application:stop(minuteman).
