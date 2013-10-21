%%% coding:utf-8
%%%-------------------------------------------------------------------
%%% @author zl
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------

-module(lc_acceptor).

%% API.
-export([start_link/2]).

%% Internal.
-export([loop/2]).

-include("log.hrl").

%% API.
-spec start_link(inet:socket(),
                 lc_listener_sup:new_socket_owner()) -> {ok, pid()}.
start_link(LSocket, Func) ->
	Pid = spawn_link(?MODULE, loop, [LSocket, Func]),
	{ok, Pid}.

%% Internal.
-spec loop(inet:socket(),
           lc_listener_sup:new_socket_owner()) -> no_return().
loop(LSocket, Func) ->
	case gen_tcp:accept(LSocket, infinity) of
		{ok, CSocket} ->
            ?DEBUG_LOG("new C socket1, fun~p", [Func]),
            {ok, Pid} = Func(CSocket),
            ?DEBUG_LOG("new C socket2,"),
            case gen_tcp:controlling_process(CSocket, Pid) of
                ok ->
                    ok;
                {error, Reason} ->
                    ?ERROR_LOG("controlling_process ~p error:~p", [Pid, Reason]),
                    gen_tcp:close(CSocket)
            end;
        {error, emfile} ->
            receive after 100 -> ok end;
        %% We want to crash if the listening socket got closed.
        {error, Reason} when Reason =/= closed ->
            ok;
        _Msg ->
            io:format("get a unknow msg~p\n", [_Msg])
    end,
	loop(LSocket, Func).
