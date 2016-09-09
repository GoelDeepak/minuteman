-module(minuteman_ct_latency_observer_SUITE).
-include_lib("common_test/include/ct.hrl").
-compile(export_all).

all() ->
      [test_init].

init_per_testcase(_, Config) ->
  application:ensure_all_started(minuteman),
  %	{ok, Pid} = minuteman_ct_latency_observer:start_link(),
	% [{pid, Pid} | Config].
  Config.

end_per_testcase(_, Config) ->
  application:stop(minuteman).
%  Pid = ?config(pid, Config),
%  unlink(Pid),
%  exit(Pid, shutdown),
%  wait_for_death(Pid).

% wait_for_death(Pid) -> wait_for_death(Pid, is_process_alive(Pid)).
% 
% wait_for_death(Pid, true) ->
%   timer:sleep(10),
%   wait_for_death(Pid);
% wait_for_death(_Pid, false) -> ok.

test_init(_Config) -> ok.
%  Pid = ?config(pid, Config).

mock_iptables() ->
  Parent = self(),
  meck:new(iptables, [passthrough, no_link]),
  meck:expect(io, check, fun(Table, Chain, Rule) ->
    {ok,[]}
  end),
  meck:expect(io, insert, fun(Table, Chain, Rule) ->
    {ok,[]}
  end).

