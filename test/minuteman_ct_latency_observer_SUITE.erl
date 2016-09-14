-module(minuteman_ct_latency_observer_SUITE).
-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include_lib("telemetry/include/telemetry.hrl").

all() ->
  [run_test_init
  ,run_test_update_vip_names
  ].

run_test_init(_Config) -> ok.

run_test_update_vip_names(_Config) ->
  #metrics{} = minuteman_ct_latency_observer:update_vip_names(#metrics{}),
  ok.

init_per_testcase(_, Config) ->
  {ok, _} = application:ensure_all_started(minuteman),
  Config.

end_per_testcase(_, _Config) -> 
  Queue = application:get_env(minuteman, queue, 50),
  ct:pal("queue ~p", [Queue]),
  application:set_env(minuteman, queue, Queue + 10),
  ok = application:stop(minuteman).
