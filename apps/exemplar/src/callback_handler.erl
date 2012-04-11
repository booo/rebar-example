-module(callback_handler).
-export([init/3, handle/2, terminate/2, handle_upload/2]).

init({tcp, http}, Req, _Opts) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    { Method, _ } = cowboy_http_req:method(Req),
    { Path, _ } = cowboy_http_req:path(Req),
    route(Method, Path, Req, State).


route('GET', _Path, Req, State) ->
    Content = mustache:render(index),
    { ok, Req2} = cowboy_http_req:reply(200, [], Content, Req),
    { ok, Req2, State};

route('POST', [<<"blobs">>], Req, State) ->
    handle_upload(Req, State);

% route('POST', [<<"blobs">>], Req, State) ->
%     case cowboy_http_req:stream_body(Req) of
%         { ok, Data, Req2 } ->
%             % io:fwrite("Some data arrived...\n"),
%             { ok, Req3 } = cowboy_http_req:chunked_reply(200, [], Req2),
%             ok = cowboy_http_req:chunk(Data, Req3),
%             % route('POST', [<<"blobs">>], Req3, State);
%             handle_upload(Req3, State),
%             { ok, Req3, State };
%         { done, Req2 } ->
%             % { ok, Req3 } = cowboy_http_req:reply(200, [], <<"A POST to `testing` happend...">>, Req2),
%             { ok, Req2, State }
%         end;

route(_Method, _Path, Req, State) ->
    {ok, Req2} = cowboy_http_req:reply(404, [], <<"Page not found...">>, Req),
    {ok, Req2, State}.

handle_upload(Req, State) ->
    % io:fwrite("Data arrived.\n"),
    case cowboy_http_req:multipart_data(Req) of
        { { headers, Headers }, Req2 } ->
            io:write(Headers),
            handle_upload(Req2, State);
        { { body, _Data }, Req2 } ->
            % io:fwrite("Some data arrived.\n"),
            % io:write(byte_size(Data)),
            % io:fwrite("\n"),
            handle_upload(Req2, State);
        { end_of_part, Req2 } ->
            io:fwrite("End of part.\n"),
            handle_upload(Req2, State);
        { eof, Req2 } ->
            io:fwrite("No more parts.\n"),
            { ok, Req3 } = cowboy_http_req:reply(200, [], <<"Done">>, Req2),
            { ok, Req3, State }

    end.


% handle_upload(Req, State) ->
%     case cowboy_http_req:stream_body(Req) of
%         { ok, Data, Req2 } ->
%             io:fwrite("Some data arrived...\n"),
%             case cowboy_http_req:chunk(Data, Req2) of
%                 ok ->
%                     io:fwrite("Chunk send...\n"),
%                     handle_upload(Req2, State),
%                     { ok, Req2, State };
%                 { error , closed } ->
%                     io:fwrite("Connection closed...\n"),
%                     { ok, Req2, State };
%                 { error, _ } ->
%                     io:fwrite("Error\n"),
%                     { ok, Req2, State }
%             end;
%         { done, Req2 } ->
%             io:fwrite("No more data...\n"),
%             { ok, Req2, State }
%     end.

%route(Req, State)
%    {Path, _} = cowboy_http_req:method(Req),
%    io:fwrite(Path ,[]),
%    io:fwrite("\n"),
%    case cowboy_http_req:stream_body(Req) of
%        {ok, Data, Req2} ->
%            io:write(Data),
%            % - {ok, Req3} = cowboy_http_req:reply(200, [], <<"Hello World!">>, Req2),
%            handle(Req2, State);
%        {done, Req2} ->
%            {ok, Req3} = cowboy_http_req:reply(200, [], <<"Hello World!">>, Req2),
%            {ok, Req3, State}
%        end.
%
%    % {ok, Req2} = cowboy_http_req:reply(200, [], <<"Hello World!">>, Req),
%    % {ok, Req2, State}.

terminate(_Req, _State) ->
    ok.

% handle('GET', [], _Req) ->
%     Content = mustache:render(index),
%     % {ok, [], <<"Hello World">>}.
%     {ok, [], Content};
%
% handle('POST', [<<"blobs">>], Req) ->
%     io:format("Bla"),
%     Body = elli_request:body_qs(Req),
%     io:write(Body),
%     io:format(<<"\n">>),
%     {ok, [], <<"helloworlda">>}.
%
% handle_event(_Event, _Data, _Args) ->
%     ok.
