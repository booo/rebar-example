-module(exemplar_server).

-behaviour(gen_server).

-export([start_link/0, say_hello/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    io:format("Starting server...",[]),
    Dispatch = [
        {'_', [{'_', callback_handler, []}]}
    ],
    {ok, Pid} = cowboy:start_listener(my_http_listener, 100,
        cowboy_tcp_transport, [{port, 8080}],
        cowboy_http_protocol, [{dispatch, Dispatch}]
    ),
    io:write(Pid),
    {ok, []}.

say_hello() ->
    gen_server:call(?MODULE, hello).

%% callbacks

handle_call(hello, _From, State) ->
    io:format("Hello from server!~n", []),
    {reply, ok, State};

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    % TODO terminate/stop (listener) cowboy here?
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
