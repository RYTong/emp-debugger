-define(Debug(T), erlide_log:erlangLog(?MODULE, ?LINE, finest, T)).
-define(DebugStack(T), erlide_log:erlangLogStack(?MODULE, ?LINE, finest, T)).
-define(Info(T), erlide_log:erlangLog(?MODULE, ?LINE, info, T)).

-define(Err(T), erlide_log:erlangLog(?MODULE, ?LINE, error, T)).

-define(SAVE_CALLS, erlang:process_flag(save_calls, 50)).

-ifdef(EWP).
-define(ewp_log(T), erlide_log:erlangLog(?MODULE, ?LINE, info, T)).
-define(ewp_info(Format, Data), ?Debug(io_lib:format(Format, Data))).
-define(ewp_err(E), ?Err(E)).
-define(ewp_err(F, D), ?Err(io_lib:format(F, D))).

-else.
-define(ewp_log(T), ok).
-define(ewp_info(F,D), ok).
-endif.

-ifdef(DEBUG).
-compile(export_all).
-ifdef(IO_FORMAT_DEBUG).
-define(D(T), io:format("~p\n", [{?MODULE, ?LINE, T}])).
-define(D(F, T), io:format("~p,~p"++F, [?MODULE, ?LINE]++T)).
-else.
-define(D(T), ?Debug(T)).
-define(D(F, T), ?Debug(T)).
-endif.
-else.
-define(D(T), ok).
-define(D(F, T), ok).
-endif.

-record(token, {kind=u, line=u, offset=u, length=u, value=u, text=u, last_line=u}).
