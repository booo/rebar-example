-module(exemplar_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
     % exemplar_sup:start_link().
     io:format("Starting server...",[]),
     Dispatch = [
         {'_', [{'_', callback_handler, []}]}
     ],
     {ok, Pid} = cowboy:start_listener(my_http_listener, 100,
         cowboy_tcp_transport, [{port, 8080}],
         cowboy_http_protocol, [{dispatch, Dispatch}]
     ),
     {ok, Pid}.

stop(_State) ->
    ok.
