%% Copyright (c) 2016-2017 Beijing RYTong Information Technologies, Ltd.
%% All rights reserved.
%%
%% No part of this source code may be copied, used, or modified
%% without the express written consent of RYTong.
%% Author: Ju.chao
%% Created: 2016-03-24
%% Description: TODO: Add description to channel_adapter_erl_template
-module('erl_indent').

%%
%% Include files
%%

-include("erlide.hrl").

%%
%% Exported Functions
%%
-compile([export_all]).

-define(INPUT_PARAMS, 'select_text').
-define(TAB_LENGTH, 'tab_length').
-define(USE_TAB, 'use_tab').
-define(START_POINT, 'start_point').

%% ----------------------------------------------------
%%         export function
%% ----------------------------------------------------
erl_indent(TabLength, UseTab, IndetStartPoint, IRandFlag, SelectText64) ->
    % io:format("TabLength---~p~n",[TabLength]),
    SelectText = base64:decode_to_string(SelectText64),
    Re = indent_lines(SelectText, IndetStartPoint, length(SelectText), TabLength, UseTab, []),
    % io:format("+++++++++++++++++++++++++++++++++++++++++++++++++++~n", []),
    % io:format("~p~n", [Re]),
    ReStr = hd(io_lib:format("~s~n", [IRandFlag++Re++IRandFlag])),
    io:put_chars(ReStr),
    "".
% IRandFlag++ReStr.


erl_indent() ->

    % io:format(" -----erlang do indent! ----- ~n", []),
    % io:format("~p~n", [init:get_arguments() ]),
    SelectText64 = script_get_init_argument(?INPUT_PARAMS),
    TabLength = case script_get_init_argument_def(?TAB_LENGTH) of
                    undefined -> 4;
                    TmpTabLen ->
                        list_to_integer(TmpTabLen)
                end,
    UseTab =  case script_get_init_argument_def(?USE_TAB) of
                  undefined -> false;
                  TmpUseTab ->
                      erlang:list_to_atom(TmpUseTab)
              end,
    IndetStartPoint = case script_get_init_argument_def(?START_POINT) of
                          undefined -> 0;
                          TmpStartP ->
                              erlang:list_to_integer(TmpStartP)
                      end,
    SelectText = base64:decode_to_string(SelectText64),
    % io:format("erlang do indent111! ~p~n", [SelectText]),
    Re = indent_lines(SelectText, IndetStartPoint, length(SelectText), TabLength, UseTab, []),
    % io:format("+++++++++++++++++++++++++++++++++++++++++++++++++++~n", []),
    % io:format("~p~n", [Re]),
    ReStr = hd(io_lib:format("~s~n", [Re])),
    io:put_chars(ReStr),
    "".

indent_lines(S, From, Length, Tablength, UseTabs, Prefs) ->
    {First, FirstLineNum, Lines} = erlide_text:get_text_and_lines(S, From, Length),
    do_indent_lines(Lines, Tablength, UseTabs, First, get_prefs(Prefs), FirstLineNum, "").


do_indent_lines([], _, _, _, _, _, A) ->
    A;
do_indent_lines([Line | Rest], Tablength, UseTabs, Text, Prefs, N, Acc) ->
    {NewI, _OldI, _AddNL} = indent_line(Text ++ Line, Line, "", N, Tablength, UseTabs, Prefs),
    NewLine0 = reindent_line(Line, NewI),
    NewLine = entab(NewLine0, UseTabs, Tablength),
    ?D(NewLine),
    do_indent_lines(Rest, Tablength, UseTabs, Text ++ NewLine, Prefs, N+1, Acc ++ NewLine).


indent_line(St, OldLine, CommandText, Tablength, UseTabs, Prefs) ->
    indent_line(St, OldLine, CommandText, -1, Tablength, UseTabs, get_prefs(Prefs)).

indent_line(St, OldLine, CommandText, N, Tablength, UseTabs, Prefs) ->
    ?D(St),
    S = erlide_text:detab(St, Tablength, all),
    StrippedCommandText = erlide_text:left_strip(CommandText),
    {Indent, AddNL} = check_add_newline(StrippedCommandText, Prefs),
    case Indent of
        true ->
            case scan(S ++ StrippedCommandText) of
                {ok, T} ->
                    LineOffsets = erlide_text:get_line_offsets(S),
                    Tr = convert_tokens(T) ++
                             [#token{kind=eof, line=size(LineOffsets)+1}],
                    LineN = case N of
                                -1 ->
                                    size(LineOffsets)+1;
                                _ ->
                                    N
                            end,
                    case indent(Tr, LineOffsets, LineN, Prefs, erlide_text:left_strip(OldLine)) of
                        {I, true} ->
                            ?D(I),
                            IS0 = reindent_line("", I),
                            IS = entab(IS0, UseTabs, Tablength),
                            {IS, erlide_text:initial_whitespace(OldLine), AddNL};
                        {I, false} ->
                            ?D(I),
                            case AddNL of
                                false ->
                                    IS0 = reindent_line("", I),
                                    IS =  entab(IS0, UseTabs, Tablength),
                                    {IS, 0, false};
                                true -> {"", 0, false}
                            end
                    end;
                Error  ->
                    Error
            end;
        false ->
            ok
    end.

%%
reindent_line(" " ++ S, I) ->
    reindent_line(S, I);
reindent_line("\t" ++ S, I) ->
    reindent_line(S, I);
reindent_line(S, I) when is_integer(I), I>0 ->
    lists:duplicate(I, $ )++S;
reindent_line(S, I) when is_integer(I) ->
    S;
reindent_line(S, I) when is_list(I) ->
    I ++ S.

%% ----------------------------------------------------
%%         Local Functions
%% ----------------------------------------------------

entab(S, false, _Tablength) ->
    S;
entab(S, true, Tablength) ->
    erlide_text:entab(S, Tablength, left).

-record(i, {anchor, indent_line, current, in_block, prefs, old_line}).

get_prefs([], OldP, Acc) ->
    Acc ++ OldP;
get_prefs([{Key, Value} | Rest], OldP, Acc) ->
    P = lists:keydelete(Key, 1, OldP),
    get_prefs(Rest, P, [{Key, Value} | Acc]).

get_prefs(Prefs) ->
    get_prefs(Prefs, default_indent_prefs(), []).

default_indent_prefs() ->
    [{before_binary_op, 4},
     {after_binary_op, 4},
     {before_arrow, 2},
     {after_arrow, 4},
     {after_unary_op, 4},
     {clause, 4},
     {'case', 4},
     {'try', 4},
     {'catch', 4},
     {'after', 4},
     {function_parameters, 2},
     {'fun', 3},
     {fun_body, 5},
     {paren, 1},
     {'<<', 2},
     {end_paren, 0}].

get_key(",") -> comma_nl;
get_key(',') -> comma_nl;
get_key(";") -> semicolon_nl;
get_key(';') -> semicolon_nl;
get_key(".") -> dot_nl;
get_key('.') -> dot_nl;
get_key(">") -> arrow_nl;
get_key('->') -> arrow_nl;
get_key(_) -> none.

indent(Tokens, LineOffsets, LineN, Prefs, OldLine) ->
    I = #i{anchor=hd(Tokens), indent_line=LineN, current=0, prefs=Prefs,
           in_block=true, old_line=OldLine},
    ?D({I, LineOffsets}),
    try
        i_form_list(Tokens, I),
        ?D(no_catch),
        {4, I#i.in_block}
    catch
        throw:{indent, A, C, Inblock} ->
            ?D({indent, A, C, Inblock}),
            {get_indent_of(A, C, LineOffsets), Inblock};
        throw:{indent_eof, A, C, Inblock} ->
            ?D({indent_eof, A, C, Inblock}),
            {get_indent_of(A, C, LineOffsets), Inblock};
        throw:{indent_to, N, Inblock} ->
            ?D(N),
            {N, Inblock};
        error:_E ->
            ?D(_E),
            {0, true}
    end.

get_indent_of(_A = #token{kind=eof}, C, _LineOffsets) ->
    C;
get_indent_of(_A = #token{line=N, offset=O}, C, LineOffsets) ->
    LO = element(N+1, LineOffsets),
    TI = O - LO,
    ?D({O, LO, C, _A}),
    TI+C.


check_add_newline(S, _Prefs) when S == "\r\n"; S == "\n"; S == "\r"; S == "" ->
    {true, false};
check_add_newline(S, Prefs) ->
    case proplists:get_value(get_key(S), Prefs) of
        1 ->
            {true, true};
        _ ->
            {false, false}
    end.



make_macro(L, NL, O, G, V0) ->
    V = list_to_atom([$? | atom_to_list(V0)]),
    #token{kind=macro, line=L+NL, offset=O, length=G+1, value=V}.



scan(S) ->
    case erlide_scan:string(S, {0, 0}) of
        {ok, T, _} ->
            ?D(erlide_scan:filter_ws(T)),
            {ok, erlide_scan:filter_ws(T)};
        Error ->
            Error
    end.


convert_tokens(Tokens) ->
    convert_tokens(Tokens, 0).

convert_tokens(Tokens, NL) ->
    convert_tokens(Tokens, 0, NL).

convert_tokens(Tokens, Offset, NL) ->
    convert_tokens(Tokens, Offset, NL, []).

convert_tokens([], _Ofs, _NL, Acc) ->
    lists:reverse(Acc);
convert_tokens([{dot, {{L, O}, G}} | Rest], Ofs, NL, Acc) ->
    T = #token{kind=dot, line=L+NL, offset=O+Ofs, length=G, text="."},
    convert_tokens(Rest, Ofs, NL, [T | Acc]);
convert_tokens([{ws, {{L, O}, G}, Txt} | Rest], Ofs, NL, Acc) ->
    T = #token{kind=ws, line=L+NL, offset=O+Ofs, length=G, text=Txt},
    convert_tokens(Rest, Ofs, NL, [T | Acc]);
convert_tokens([{'?', {{L, O1}, G1}}, {'?', {{L, O2}, G2}} | Rest],
               Ofs, NL, Acc) ->
    C1 = #token{kind=$?, line=L+NL, offset= O1+Ofs, length=G1, text="?"},
    C2 = #token{kind=$?, line=L+NL, offset= O2+Ofs, length=G2, text="?"},
    convert_tokens(Rest, Ofs, NL, [C2, C1 | Acc]);
convert_tokens([{'?', {{L, O}, 1}}, {var, {{L, O1}, G}, V} | Rest],
               Ofs, NL, Acc) when O1=:=O+1->
    T = make_macro(L, NL, O, G, V),
    convert_tokens(Rest, Ofs, NL, [T | Acc]);
convert_tokens([{'?', {{L, O}, 1}}, {atom, {{L, O1}, G}, V} | Rest],
               Ofs, NL, Acc) when O1=:=O+1->
    T = make_macro(L, NL, O, G, V),
    convert_tokens(Rest, Ofs, NL, [T | Acc]);
convert_tokens([{'?', {{L, O}, 1}}, {atom, {{L, O1}, G}, V, _Txt} | Rest],
               Ofs, NL, Acc) when O1=:=O+1->
    T = make_macro(L, NL, O, G, V),
    convert_tokens(Rest, Ofs, NL, [T | Acc]);
convert_tokens([{K, {{L, O}, G}} | Rest], Ofs, NL, Acc) ->
    T = #token{kind=K, line=L+NL, offset=O+Ofs, length=G},
    convert_tokens(Rest, Ofs, NL, [T | Acc]);
convert_tokens([{K, {{L, O}, G}, V} | Rest], Ofs, NL, Acc) ->
    T = #token{kind=K, line=L+NL, offset=O+Ofs, length=G, value=V},
    convert_tokens(Rest, Ofs, NL, [T | Acc]);
convert_tokens([{K, {{L, O}, G}, V, Txt} | Rest], Ofs, NL, Acc) ->
    T = #token{kind=K, line=L+NL, offset=O+Ofs, length=G, value=V, text=Txt},
    convert_tokens(Rest, Ofs, NL, [T | Acc]).

%% @doc get the argument form the initial arg list
script_get_init_argument(Key) ->
    case init:get_argument(Key) of
        error ->
            throw(lists:concat(["required params:", Key]));
        {ok, Result} ->
            [Value] = hd(Result),
            Value
    end.

script_get_init_arguments(Key) ->
    case init:get_argument(Key) of
        error ->
            throw(lists:concat(["required params:", Key]));
        {ok, Result} ->
            hd(Result)
    end.

script_get_init_argument_def(Key) ->
    script_get_init_argument_def(Key, undefined).
script_get_init_argument_def(Key, DefVal) ->
    case init:get_argument(Key) of
        error ->
            DefVal;
        {ok, Result} ->
            [Value] = hd(Result),
            Value
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_check_aux([#token{line=K} | _], #i{indent_line=L, anchor=A, current=C, in_block=Inblock}) when K >= L ->
    {indent, A, C, Inblock};
i_check_aux([eof | _], #i{anchor=A, current=C, in_block=Inblock}) ->
    {indent_eof, A, C, Inblock};
i_check_aux([#token{kind=eof} | _], #i{anchor=A, current=C, in_block=Inblock}) ->
    {indent_eof, A, C, Inblock};
i_check_aux([], I) ->
    i_check_aux([eof], I);
i_check_aux(_, _) ->
    not_yet.

i_check(T, I) ->
    case i_check_aux(T, I) of
        not_yet ->
            not_yet;
        Throw ->
            ?D({T, I}),
            throw(Throw)
    end.

indent_by(Key, Prefs) ->
    proplists:get_value(Key, Prefs, 0).

head([H | _]) -> H;
head(H) -> H.

i_with(W, I) ->
    I#i{current=indent_by(W, I#i.prefs)}.

i_with(W, A, I) ->
    I#i{current=indent_by(W, I#i.prefs), anchor=head(A)}.

i_with(W1, W2, A, I) ->
    I#i{current=indent_by(W1, I#i.prefs)+indent_by(W2, I#i.prefs),
        anchor=head(A)}.

i_with_old_or_new_anchor(none, ANew, I) ->
    i_with(none, ANew, I);
i_with_old_or_new_anchor(AOld, _ANew, I) ->
    i_with(none, AOld, I).

i_par_list(R0, I0) ->
    I1 = I0#i{in_block=false},
    R1 = i_kind('(', R0, I1),
    I2 = i_with(end_paren, R0, I1),
    R2 = i_parameters(R1, I1),
    i_end_paren(R2, I2).

i_expr([], _I, _A) ->
    {[], eof};
i_expr(R0, I0, A) ->
    R1 = i_comments(R0, I0),
    I1 = i_with_old_or_new_anchor(A, R1, I0),
    R2 = i_1_expr(R1, I1),
    ?D(R1),
    case i_sniff(R1) of
        Kind when Kind=:=string; Kind=:=macro ->
            case i_sniff(i_kind(Kind, R1, I1)) of
                Kind2 when Kind2=:=string; Kind2=:=macro ->
                    i_expr(R2, i_with(after_binary_op, I1), A);
                _ ->
                    i_expr_rest(R2, I1, I1#i.anchor)
            end;
        _ ->
            i_expr_rest(R2, I1, I1#i.anchor)
    end.

i_expr_rest(R0, I, A) ->
    case i_sniff(R0) of
        '(' -> % function call
            I1 = i_with(function_parameters, A, I),
            R1 = i_par_list(R0, I1),
            i_expr_rest(R1, I1, A);
        eof ->
            {R0, A};
        '#' -> % record something
            ?D(I),
            i_record(R0, I);
        ':' -> % external function call
            R1 = i_kind(':', R0, I),
            R2 = i_1_expr(R1, I),
            {R3, A1} = i_expr_rest(R2, I, A),
            {R3, A1};
        '||' -> % list comprehension
            R1 = i_kind('||', R0, I),
            R2 = i_expr_list(R1, I),
            {R2, A};
        '<=' -> % within binary comprehension
            R1 = i_kind('<=', R0, I),
            {R2, _A} = i_expr(R1, i_with(after_binary_op, I), none),
            {R2, A};
        '=' -> % match/assignment
            R1 = i_binary_op(R0, i_with(before_binary_op, I)),
            {R2, _A} = i_expr(R1, i_with(after_binary_op, I), none),
            {R2, A};
        _ ->
            case is_binary_op(i_sniff(R0)) of
                true ->
                    ?D({A, R0}),
                    R1 = i_binary_op(R0, i_with(before_binary_op, I)),
                    {R2, _A} = i_expr(R1, i_with(after_binary_op, I), A),
                    {R2, A};
                false ->
                    ?D({R0, A}),
                    {R0, A}
            end
    end.

i_expr_list(R, I) ->
    i_expr_list(R, I, none).

i_expr_list(R0, I0, A0) ->
    R1 = i_comments(R0, I0),
    ?D(R1),
    {R2, A1} = i_expr(R1, I0, A0),
    ?D({R2, A1}),
    I1 = i_with_old_or_new_anchor(A0, A1, I0),
    case i_sniff(R2) of
        ',' ->
            R3 = i_kind(',', R2, I1),
            i_expr_list(R3, I1, I1#i.anchor);
        _ ->
            R2
    end.

i_binary_expr_list(R, I) ->
    i_binary_expr_list(R, I, none).

i_binary_expr_list(R0, I0, A0) ->
    R1 = i_comments(R0, I0),
    ?D(R1),
    case i_sniff(R1) of
        '>>' ->
            R1;
        _ ->
            {R2, A1} = i_binary_expr(R1, I0),
            I1 = i_with_old_or_new_anchor(A0, A1, I0),
            case i_sniff(R2) of
                ',' ->
                    R3 = i_kind(',', R2, I1),
                    i_binary_expr_list(R3, I1, I1#i.anchor);
                Kind when Kind=:='||'; Kind=:='<='; Kind=:='<-' ->
                    % binary comprehension
                    R3 = i_kind('||', R2, I1),
                    i_binary_expr_list(R3, I1, I1#i.anchor);
                _ ->
                    R2
            end
    end.

i_binary_expr(R0, I0) ->
    {R1, A1} = i_binary_sub_expr(R0, I0),
    I1 = i_with(none, A1, I0),
    ?D(head(R1)),
    R2 = case i_sniff(R1) of
             Kind when Kind==':'; Kind=='/' ->
                 R11 = i_kind(Kind, R1, I1),
                 i_binary_specifiers(R11, I1);
             _ ->
                 R1
         end,
    {R2, A1}.

i_binary_sub_expr(R0, I0) ->
    case i_sniff(R0) of
        Kind when Kind=='('; Kind=='<<'; Kind==macro ->
            i_expr(R0, I0, none);
        Kind when Kind==var; Kind==string; Kind==integer; Kind==char ->
            R1 = i_comments(R0, I0),
            R2 = i_kind(Kind, R1, I0),
            {i_1_expr(R2, I0), hd(R1)}
    end.

i_binary_specifiers(R0, I) ->
    R1 = i_binary_specifier(R0, I),
    ?D(R1),
    case i_sniff(R1) of
        Kind when Kind==':'; Kind=='-'; Kind=='/' ->
            R2 = i_kind(Kind, R1, I),
            i_binary_specifiers(R2, I);
        _ ->
            ?D(R1),
            R1
    end.

i_binary_specifier(R0, I) ->
    case i_sniff(R0) of
        '(' ->
            {R1, _A} = i_expr(R0, I, none),
            R1;
        Kind when Kind==var; Kind==string; Kind==integer; Kind==atom; Kind==char ->
            R1 = i_comments(R0, I),
            R2 = i_kind(Kind, R1, I),
            i_1_expr(R2, I)
    end.

i_predicate_list(R, I) ->
    i_predicate_list(R, I, none).

i_predicate_list(R0, I0, A0) ->
    R1 = i_comments(R0, I0),
    {R2, A1} = i_expr(R1, I0, A0),
    I1 = i_with_old_or_new_anchor(A0, A1, I0),
    case i_sniff(R2) of
        Kind when Kind==','; Kind==';' ->
            R3 = i_kind(Kind, R2, I1),
            i_predicate_list(R3, I1, I1#i.anchor);
        _ ->
            {R2, A1}
    end.

i_binary_op(R0, I) ->
    i_one(R0, I).

i_end_paren_or_expr_list(R, I0) ->
    i_check(R, I0),
    case i_sniff(R) of
        Kind when Kind=='}'; Kind==']'; Kind==')' ->
            R;
        _ ->
            I1 = i_with(none, R, I0),
            i_expr_list(R, I1)
    end.

i_end_or_expr_list(R, I0) ->
    i_check(R, I0),
    case i_sniff(R) of
        'end' ->
            R;
        _ ->
            I1 = i_with(none, R, I0),
            i_expr_list(R, I1)
    end.

i_1_expr([#token{kind=atom} | _] = R, I) ->
    i_one(R, I);
i_1_expr([#token{kind=integer}, #token{kind=dot} | _] = R, I) ->
    i_two(R, I);
i_1_expr([#token{kind=integer} | _] = R, I) ->
    i_one(R, I);
i_1_expr([#token{kind=string} | _] = R, I) ->
    i_one(R, I);
i_1_expr([#token{kind=macro} | _] = R, I) ->
    i_macro(R, I);
i_1_expr([#token{kind=float} | _] = R, I) ->
    i_one(R, I);
i_1_expr([#token{kind=var} | _] = R, I) ->
    i_one(R, I);
i_1_expr([#token{kind=char} | _] = R, I) ->
    i_one(R, I);
i_1_expr([#token{kind=Kind} | _] = R0, I0) when Kind=='{'; Kind=='['; Kind=='(' ->
    R1 = i_kind(Kind, R0, I0),
    I1 = i_with(paren, R0, I0),
    R2 = i_end_paren_or_expr_list(R1, I1#i{in_block=false}),
    I2 = i_with(end_paren, R0, I0),
    i_end_paren(R2, I2);
i_1_expr([#token{kind='<<'} | _] = R0, I0) ->
    R1 = i_kind('<<', R0, I0),
    I1 = i_with('<<', R0, I0),
    R2 = i_binary_expr_list(R1, I1#i{in_block=false}),
    I2 = i_with(end_paren, R0, I0),
    i_kind('>>', R2, I2);
i_1_expr([#token{kind='#'} | _] = L, I) ->
    ?D('#'),
    {R, _A} = i_record(L, I#i{in_block=false}),
    R;
i_1_expr([#token{kind='case'} | _] = R, I) ->
    i_case(R, I);
i_1_expr([#token{kind='if'} | _] = R, I) ->
    i_if(R, I);
i_1_expr([#token{kind='begin'} | _] = R0, I0) ->
    R1 = i_kind('begin', R0, I0),
    I1 = i_with('case', R0, I0),
    R2 = i_end_or_expr_list(R1, I1#i{in_block=false}),
    i_block_end('begin', R0, R2, I0);
%%     R1 = i_kind('begin', R0, I0),
%%     I1 = i_with('case', R0, I0),
%%     R2 = i_end_or_expr_list(R1, I1#i{in_block=false}),
%%     i_block_end(T#token.kind, R2, I0);
i_1_expr([#token{kind='receive'} | _] = R, I) ->
    i_receive(R, I);
i_1_expr([#token{kind='fun'}=T | R0], I) ->
    I1 = i_with('fun', T, I),
    case i_sniff(R0) of
        '(' ->
            R1 = i_fun_clause_list(R0, I1),
            i_kind('end', R1, I);
        _ ->
            {R1, _A} = i_expr(R0, I1, none),
            R1
    end;
i_1_expr([#token{kind='try'} | _] = R, I) ->
    ?D(R),
    i_try(R, I);
i_1_expr(R0, I) ->
    R1 = i_comments(R0, I),
    case is_unary_op(R1) of
        true ->
            R2 = i_one(R1, I),
            i_1_expr(R2, i_with(after_unary_op, R2, I));
        false ->
            R1
    end.

i_macro(R0, I) ->
    R = i_one(R0, I),
    i_macro_rest(R, I).

i_macro_rest(R0, I) ->
    case i_sniff(R0) of
        Paren when Paren=:='('; Paren=:='{'; Paren=:='[' ->
            R1 = i_kind(Paren, R0, I),
            R2 = i_parameters(R1, I),
            R3 = i_end_paren(R2, I),
            i_macro_rest(R3, I);
        K when K=:=':'; K=:=','; K=:=';'; K=:=')'; K=:='}'; K=:=']'; K=:='>>'; K=:='of';
               K=:='end'; K=:='->'; K =:= '||' ->
            R0;
        K ->
            case erlide_scan:reserved_word(K) of
                true ->
                    R0;
                _ ->
                    case is_binary_op(K) of
                        false ->
                            R2 = i_comments(R0, I),
                            i_one(R2, I);
                        true ->
                            R0
                    end
            end
    end.

i_if(R0, I0) ->
    I1 = I0#i{in_block=true},
    R1 = i_kind('if', R0, I1),
    I2 = i_with('case', R0, I1),
    R2 = i_if_clause_list(R1, I2, none),
    i_block_end('if', R0, R2, I1).

i_case(R0, I0) ->
    I1 = I0#i{in_block=true},
    R1 = i_kind('case', R0, I1),
    I2 = i_with('case', R0, I1),
    {R2, _A} = i_expr(R1, I2#i{in_block=false}, none),
    R3 = i_kind('of', R2, I2),
    R4 = i_clause_list(R3, I2),
    i_block_end('case', R0, R4, I1).

i_receive(R0, I0) ->
    I1 = I0#i{in_block=true},
    R1 = i_kind('receive', R0, I1),
    I2 = i_with('case', R0, I1),
    R2 = case i_sniff(R1) of
             'after' ->
                 R1;
             _ ->
                 i_clause_list(R1, I2)
         end,
    R4 = case i_sniff(R2) of
             'after' ->
                 ?D('after'),
                 R3 = i_kind('after', R2, I2),
                 I3 = i_with('case', clause, R0, I1),
                 i_after_clause(R3, I3);
             _ ->
                 R2
         end,
    i_block_end('receive', R0, R4, I1).



i_try(R0, I0) ->
    I1 = I0#i{in_block=true},
    R1 = i_kind('try', R0, I1),
    I2 = i_with('try', R0, I1),
    R2 = i_expr_list(R1, I2),
    ?D(R2),
    R3 = case i_sniff(R2) of
             'of' ->
                 R21 = i_kind('of', R2, I1),
                 i_clause_list(R21, I2);
             _ ->
                 R2
         end,
    R4 = case i_sniff(R3) of
             'catch' ->
                 R31 = i_kind('catch', R3, I1),
                 I11 = i_with('catch', R3, I1),
                 i_catch_clause_list(R31, I11);
             _ ->
                 R3
         end,
    R5 = case i_sniff(R4) of
             'after' ->
                 R41 = i_kind('after', R4, I1),
                 I12 = i_with('after', R4, I1),
                 i_expr_list(R41, I12);
             _ ->
                 R4
         end,
    i_block_end('try', R0, R5, I0).

is_binary_op([T | _]) ->
    is_binary_op(T);
is_binary_op(#token{kind=Kind}) ->
    erlide_text:is_op2(Kind);
is_binary_op(Kind) ->
    erlide_text:is_op2(Kind).

is_unary_op([T | _]) ->
    is_unary_op(T);
is_unary_op(#token{kind=Kind}) ->
    erlide_text:is_op1(Kind).

i_block_end(_Begin, R0, R1, I0) ->
    I1 = i_with(end_paren, R0, I0),
    i_kind('end', R1, I1).

i_one(R0, I) ->
    [_ | R] = i_comments(R0, I),
    R.

i_two(R0, I) ->
    R1 = i_one(R0, I),
    i_one(R1, I).

i_parameters(R, I) ->
    i_check(R, I),
    case i_sniff(R) of
        ')' ->
            R;
        _ ->
            i_expr_list(R, I#i{in_block=false})
    end.

i_record([#token{kind='#'} | R0], I0) ->
    I = I0#i{in_block=false},
    R1 = i_comments(R0, I),
    ?D(R1),
    R2 = i_atom_or_macro(R1, I),
    ?D(R2),
    case i_sniff(R2) of
        '.' ->
            R3 = i_kind('.', R2, I),
            {R4, _A} = i_expr(R3, I, none),
            ?D(R4),
            {R4, I#i.anchor};
        '{' ->
            i_expr(R2, I, none);
        '?' ->
            i_expr(R2, I, none);
        _ ->
            {R2, hd(R1)}
    end.

comment_kind("%%%" ++ _) ->
    comment_3;
comment_kind("%%" ++ _) ->
    comment_2;
comment_kind("%" ++ _) ->
    comment_1;
comment_kind(_) ->
    comment_0.

i_comments([#token{kind=comment, value=V} = C | Rest], I) ->
    case comment_kind(V) of
        comment_3 ->
            case i_check_aux([C], I) of
                not_yet ->
                    not_yet;
                _ ->
                    ?D(I),
                    throw({indent_to, 0, I#i.in_block})
            end;
        _ ->
            i_check([C], I)
    end,
    i_comments(Rest, I);
i_comments(Rest, I) ->
    i_check(Rest, I),
    Rest.

skip_comments([]) ->
    [];
skip_comments([#token{kind=comment} | Rest]) ->
    skip_comments(Rest);
skip_comments(Rest) ->
    Rest.


i_atom_or_macro(R0, I) ->
    case i_sniff(R0) of
        atom ->
            i_kind(atom, R0, I);
        macro ->
            {R, _} = i_expr(R0, I, none),
            R
    end.
i_kind(Kind, R0, I) ->
    R1 = i_comments(R0, I),
    [#token{kind=Kind} | R2] = R1,
    R2.

i_end_paren(R0, I) ->
    R1 = i_comments(R0, I),
    i_end_paren_1(R1, I).

i_end_paren_1([#token{kind=Kind} | _] = R, I) when Kind==')'; Kind=='}'; Kind==']'; Kind=='>>'; Kind==eof ->
    i_kind(Kind, R, I).

i_form_list(R0, I) ->
    R = i_form(R0, I),
    i_form_list(R, I).

i_form(R0, I) ->
    R1 = i_comments(R0, I),
    case i_sniff(R1) of
        '-' ->
            i_declaration(R1, I);
        _ ->
            R2 = i_clause(R1, I),
            case i_sniff(R2) of
                dot ->
                    i_kind(dot, R2, I);
                ';' ->
                    i_kind(';', R2, I);
                _ ->
                    R2
            end
    end.

i_declaration(R0, I) ->
    i_check(R0, I),
    R1 = i_kind('-', R0, I),
    case skip_comments(R1) of
        [#token{kind='spec'} | _] ->
            R2 = i_kind('spec', R1, I),
            i_form(R2, I);
        [#token{kind=atom, value='type'} | _] ->
            R2 = i_kind(atom, R1, I),
            i_type(R2, I);
        _ ->
            {R2, _A} = i_expr(R1, I, none),
            i_kind(dot, R2, I)
    end.

i_type(R0, I0) ->
    {R1, _A1} = i_expr(R0, I0, none),
    i_kind(dot, R1, I0).

i_fun_clause(R0, I0) ->
    R1 = i_comments(R0, I0),
    R2 = i_par_list(R1, I0),
    I1 = i_with(before_arrow, R0, I0#i{in_block=false}),
    R3 = case i_sniff(R2) of
             'when' ->
                 R21 = i_kind('when', R2, I1),
                 {R22, _A} = i_predicate_list(R21, I1),
                 R22;
             _ ->
                 R2
         end,
    R4 = i_kind('->', R3, I1),
    I2 = i_with(fun_body, R1, I0),
    i_expr_list(R4, I2#i{in_block=true}).

i_fun_clause_list(R, I) ->
    ?D(R),
    R0 = i_fun_clause(R, I),
    case i_sniff(R0) of
        ';' ->
            R1 = i_kind(';', R0, I),
            i_fun_clause_list(R1, I);
        _ ->
            R0
    end.

i_after_clause(R0, I0) ->
    {R1, _A} = i_expr(R0, I0, none),
    R2 = i_kind('->', R1, I0),
    i_expr_list(R2, I0#i{in_block=true}).

i_clause(R0, I) ->
    {R1, A} = i_expr(R0, I, none),
    I1 = i_with(before_arrow, A, I),
    R2 = case i_sniff(R1) of
             'when' ->
                 R11 = i_kind('when', R1, I1),
                 {R12, _A} = i_predicate_list(R11, I1),
                 R12;
             _ ->
                 R1
         end,
    I2 = I1#i{in_block=true},
    R3 = i_kind('->', R2, I2),
    I3 = i_with(after_arrow, I2),
    R = i_expr_list(R3, I3),
    ?D(R),
    R.

i_clause_list(R, I) ->
    ?D(R),
    R0 = i_clause(R, I),
    ?D(R0),
    case i_sniff(R0) of
        ';' ->
            R1 = i_kind(';', R0, I),
            i_clause_list(R1, I);
        _ ->
            R0
    end.

i_if_clause(R0, I0) ->
    {R1, A} = i_predicate_list(R0, I0),
    I1 = i_with(before_arrow, A, I0),
    R2 = i_kind('->', R1, I1),
    I2 = I1#i{in_block=true},
    I3 = i_with(after_arrow, I2),
    R = i_expr_list(R2, I3),
    ?D(R),
    {R, A}.

i_if_clause_list(R0, I0, A0) ->
    {R1, A1} = i_if_clause(R0, I0),
    ?D({A1, R1}),
    I1 = i_with_old_or_new_anchor(A0, A1, I0),
    ?D(I1),
    case i_sniff(R1) of
        ';' ->
            ?D(a),
            R2 = i_kind(';', R1, I0),
            i_if_clause_list(R2, I1, A1);
        _ ->
            ?D(b),
            R1
    end.

i_catch_clause(R0, I0) ->
    R1 = i_comments(R0, I0),
    ?D(R1),
    R2 = case i_sniff(R1) of
             atom -> i_kind(atom, R1, I0);
             var -> i_kind(var, R1, I0)
         end,
    ?D(R2),
    R3 = i_kind(':', R2, I0),
    ?D(R3),
    {R4, _A} = i_expr(R3, I0, none),
    ?D(R4),
    I1 = i_with(before_arrow, R1, I0),
    R5 = case i_sniff(R4) of
             'when' ->
                 R41 = i_kind('when', R4, I1),
                 {R42, _A} = i_predicate_list(R41, I1),
                 R42;
             _ ->
                 R4
         end,
    ?D(R5),
    R6 = i_kind('->', R5, I1),
    ?D(R6),
    I2 = i_with(clause, R1, I0),
    R = i_expr_list(R6, I2),
    R.

i_catch_clause_list(R, I) ->
    R0 = i_catch_clause(R, I),
    ?D(R0),
    case i_sniff(R0) of
        ';' ->
            R1 = i_kind(';', R0, I),
            ?D(R1),
            i_catch_clause_list(R1, I);
        _ ->
            R0
    end.

i_sniff(L) ->
    case skip_comments(L) of
        [] ->
            eof;
        [#token{kind=Kind} | _] ->
            Kind
    end.
