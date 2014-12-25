-module(cards_dealer).
-behaviour(cowboy_http_handler).

%% API
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

-record(state, {
}).

init(_, Req, _Opts) ->
  {ok, Req, #state{}}.

handle(Req, State=#state{}) ->
  {Method, Req1} = cowboy_req:method(Req),
  {Controller,_} = cowboy_req:binding(controller, Req1),
  {Action,_} = cowboy_req:binding(action, Req1),
  io:format("Controller : ~p, Action : ~p, Method : ~p~n",[Controller,Action,Method]),
  Req2 = cowboy_req:set_resp_header(<<"access-control-allow-methods">>, <<"GET, POST, PUT, DELETE, OPTIONS">>, Req1),
  Req3 = cowboy_req:set_resp_header(<<"access-control-allow-origin">>, <<"*">>, Req2),
  PolicyModuleNameList = access_policy:get(Controller, Action),
  {AccessStatus, Req4, Opts} = access_policy:evaluate(PolicyModuleNameList, Req3),
  cards_res:reply(AccessStatus, {Method, Controller, Action}, Req4, Opts, State).


terminate(_Reason, _Req, _State) ->
  ok.
