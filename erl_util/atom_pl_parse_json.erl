%% @author jcrom
%% @doc @todo Add description to test.


-module(atom_pl_parse_json).

%% ====================================================================
%% API functions
%% ====================================================================
-compile([export_all]).

-define(CHANNEL_CONF, 'channel_conf').
-define(CHANNEL_RPCOL, 'col_id').
-define(CHANNEL_RPCHA, 'cha_id').
-define(CHA, 'channels').
-define(COLL, 'collections').
-define(ID, 'id').
-define(TYPE, 'type').
-define(NAME, 'name').
-define(ENTRY, 'entry').
-define(PROPS, 'props').
-define(VIEWS, 'views').
-define(APP, 'app').
-define(URL, 'url').
-define(UID, 'uid').
-define(STATE, 'state').
-define(ITEMS, 'items').
-define(SEPRATOR, "|").
-define(TMP_JSON, "tmp_channel_json.json").

% @doc edit channel detail information
edit_cha() ->
  ConfFile = script_get_init_argument(?CHANNEL_CONF),
  Id = script_get_init_argument_def(?ID),
  Name = script_get_init_argument_def(?NAME),
  App = script_get_init_argument_def(?APP),
  Entry = script_get_init_argument_def(?ENTRY),
  Views = script_get_init_argument_def(?VIEWS),
  Props = script_get_init_argument_def(?PROPS),
  States = script_get_init_argument_def(?STATE),

  ChaViews = string:tokens(Views, ?SEPRATOR),
  ChaProps = string:tokens(Props, ?SEPRATOR),
  CChaViews = format_view(ChaViews),
  CChaProps = format_params(ChaProps),
  NewState = list_to_integer(States),
  NewCha = new_channel(Id, App, Name, Entry, CChaViews, CChaProps, NewState),

  check_conf_file(ConfFile),
  ConfC = consult_file(ConfFile),
  CollList = proplists:get_value(?COLL, ConfC),
  ChaList = proplists:get_value(?CHA, ConfC),
  NewChaList = do_remove_cha(ChaList, [Id]),

  NewReCol = [{?CHA, [NewCha|NewChaList]}, {?COLL, CollList}],
  New_con = lists:flatten(io_lib:format("~p.~n~p.",NewReCol)),
  file:write_file(ConfFile, New_con).


format_view("undefined") ->
    undefined;
format_view("") ->
    undefined;
format_view(Def)->
    format_view(Def, []).

format_view([TranCode, View|Next], Acc) ->
  format_view(Next, [{TranCode, View}|Acc]);
format_view(_, Acc) ->
  Acc.

format_params("undefined") ->
    [];
format_params("") ->
    [];
format_params(Def)->
    format_params(Def, []).

format_params(["method", Value|Next], Acc) ->
  format_params(Next, [{'method', list_to_atom(Value)}|Acc]);
format_params(["encrypt", Value|Next], Acc) ->
  format_params(Next, [{'encrypt', to_integer(Value)}|Acc]);
format_params([Key, Value|Next], Acc) ->
  format_params(Next, [{Key, Value}|Acc]);
format_params(_, Acc) ->
  Acc.

new_channel(Id, App, Name, Entry, Views, Params, State)->
    [{id, Id},
     {app, App},
     {name, Name},
     {entry, list_to_atom(Entry)},
     {views, Views},
     {props, Params},
     {state, State}].

% @doc edit collection detail information
edit_col() ->
  % io:format("asdasdads-------~n", []),
  ConfFile = script_get_init_argument(?CHANNEL_CONF),
  ColId = script_get_init_argument_def(?ID),
  ColName = script_get_init_argument_def(?NAME),
  ColApp = script_get_init_argument_def(?APP),
  ColType = script_get_init_argument_def(?TYPE),
  ColUrl = script_get_init_argument_def(?URL),
  ColUid = script_get_init_argument_def(?UID),
  ColState = script_get_init_argument_def(?STATE),
  ColItemsD = script_get_init_argument_def(?ITEMS),
  ColItems = string:tokens(ColItemsD, ?SEPRATOR),
  % NewApp = check_coll_app(ColApp),
  NewUrl = check_coll_default(ColUrl),
  NewUid = check_coll_default(ColUid),
  NewType = list_to_integer(ColType),
  NewState = list_to_integer(ColState),
  %% new_item(Id, Type, order)
  Items = format_item(ColItems),
  NewCol = new_collection(ColId, ColApp, ColName, NewUrl, NewUid, NewType, NewState, Items),

  check_conf_file(ConfFile),
  ConfC = consult_file(ConfFile),
  CollList = proplists:get_value(?COLL, ConfC),
  ChaList = proplists:get_value(?CHA, ConfC),
  NewColList = do_remove_col(CollList, [ColId, NewType]),

  NewReCol = [{?CHA, ChaList}, {?COLL, [NewCol|NewColList]}],
  New_con = lists:flatten(io_lib:format("~p.~n~p.",NewReCol)),
  file:write_file(ConfFile, New_con).

format_item(Items) ->
  % io:format("~p~n", [Items]),
  format_item(Items, []).

format_item([ItemId, ItemType, ItemOrder|Next], Acc) ->
  format_item(Next, [new_item(ItemId, ItemType, ItemOrder)|Acc]);
format_item(_, Acc) ->
  Acc.

% check_coll_app(App) when is_list(App)->
%     list_to_atom(App);
% check_coll_app(App) ->
%     App.

check_coll_default("undefined") ->
    undefined;
check_coll_default("") ->
    undefined;
check_coll_default(Def)->
    Def.

new_collection(Id, App, Name, Url, Uid, Type, State, Item)->
    [{id, Id},
     {app, App},
     {name, Name},
     {url, Url},
     {user_id, Uid},
     {type, Type},
     {state, State},
     {items, Item}].

new_item(Id, Type, Index)->
    [{item_id,Id},{item_type, to_integer(Type)},{menu_order,to_integer(Index)}].


%% @doc remove collection
remove_col() ->
  ConfFile = script_get_init_argument(?CHANNEL_CONF),
  Col_ids = script_get_init_arguments(?CHANNEL_RPCOL),
  % io:format("~p~n", [Col_ids]),
  [_|ACol_ids] = Col_ids,
  check_conf_file(ConfFile),
  ConfC = consult_file(ConfFile),
  CollList = proplists:get_value(?COLL, ConfC),
  ChaList = proplists:get_value(?CHA, ConfC),
  NewColList = do_remove_col(CollList, ACol_ids),

  NewCol = [{?COLL, NewColList}, {?CHA, ChaList}],
  New_con = lists:flatten(io_lib:format("~p.~n~p.",NewCol)),
  file:write_file(ConfFile, New_con).

do_remove_col(CollList, ReList) ->
    {IdList, DList} = filter_col_id(ReList),
    lists:foldr(fun(Col, Acc) ->
                        ItemId = proplists:get_value(?ID, Col),
                        case lists:member(ItemId, IdList) of
                            true ->
                              ItemType = proplists:get_value(?TYPE, Col),
                              TmpType = proplists:get_value(ItemId, DList),
                              case ItemType of
                                TmpType ->
                                  Acc;
                                _ ->
                                  [Col|Acc]
                              end;
                            _ -> [Col|Acc]
                        end
                end,
                [], CollList).

filter_col_id(IdList) ->
  filter_col_id(IdList,[], []).
filter_col_id([Id, Key|Next], Acc, AAcc) ->
  filter_col_id(Next, [Id|Acc], [{Id, to_integer(Key)}|AAcc]);
filter_col_id(_, Acc, AAcc) ->
  {Acc, AAcc}.


remove_channel() ->
  ConfFile = script_get_init_argument(?CHANNEL_CONF),
  Cha_ids = script_get_init_arguments(?CHANNEL_RPCHA),
  % io:format("~p", [Cha_ids]),
  [_|ACha_ids] = Cha_ids,
  check_conf_file(ConfFile),
  ConfC = consult_file(ConfFile),
  CollList = proplists:get_value(?COLL, ConfC),
  ChaList = proplists:get_value(?CHA, ConfC),
  NewChaList = do_remove_cha(ChaList, ACha_ids),

  NewCha = [{?COLL, CollList}, {?CHA, NewChaList}],
  New_con = lists:flatten(io_lib:format("~p.~n~p.",NewCha)),
  file:write_file(ConfFile, New_con).


do_remove_cha(ChaList, Id) ->
    lists:foldr(fun(Cha, Acc) ->
                        ItemId = proplists:get_value(?ID, Cha),
                        case lists:member(ItemId, Id) of
                            true -> Acc;
                            _ -> [Cha|Acc]
                        end
                end,
                [], ChaList).


% @doc 解析channel.conf
parse() ->
    try
      ConfFile = script_get_init_argument(?CHANNEL_CONF),
      % io:format("~p~n",[ConfFile]),
      check_conf_file(ConfFile),
      ConfC = consult_file(ConfFile),
      %%io:format("P---~p~n, ConfFile--~p~n", [Params, ConfFile]),
      {_, Result, _} = decode(ConfC),
      %%io:format("Result ~p~n", [Result]),
      Result2 = encode(Result),
      io:format("~s", [Result2])
    catch
      Type:Err ->
        Err_re = hd(io_lib:format("~s~n", [Err])),
        io:put_chars(standard_error, Err_re)
    end.

test() ->
    ConfFile = script_get_init_argument(?CHANNEL_CONF),
    check_conf_file(ConfFile),
    ConfC = consult_file(ConfFile),
    %%io:format("P---~p~n, ConfFile--~p~n", [Params, ConfFile]),
    {_, Result, _} = decode(ConfC),
    %%io:format("Result ~p~n", [Result]),
    Result2 = encode(Result),
    write_tmp_f(ConfFile, Result2),
    io:format("~s", [Result2]).


test(ConfFile) ->

    check_conf_file(ConfFile),
    ConfC = consult_file(ConfFile),
    % io:format("ConfFile--~p~n", [ConfFile]),
    {_, Result, _} = decode(ConfC),
    % io:format("Result ~p~n", [Result]),
    Result2 = encode(Result),
    write_tmp_f(ConfFile, Result2),
    Result2.

write_tmp_f(Path, C) ->
    Dir = filename:dirname(Path),
    Name = filename:join([Dir, ?TMP_JSON]),
    % io:format("Name---~p~n", [Name]),
    file:write_file(Name, [C]).

%% ====================================================================
%% Internal functions
%% ====================================================================
%% @doc convert parameters from atom to list
a2l(List) when is_list(List) -> List;
a2l(Atom) when is_atom(Atom) -> atom_to_list(Atom).


%% @doc read the content of channel config file
consult_file(ConfFile) ->
    case file:consult(ConfFile) of
        {ok, C} ->
            C;
        _E ->
            % io:format("read file error:~p~n", [E]),
            throw("Read the channel conf file failed, please checked the file content!")
    end.

%% @doc check if the channel config file is exists.
check_conf_file(ConfFile) ->
    case filelib:is_file(ConfFile) of
        true ->
            go_on;
        _ ->
            throw("There's no Channel.conf file, this project maybe not a emp project!")
    end.

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
    case init:get_argument(Key) of
        error ->
            undefined;
        {ok, Result} ->
            [Value] = hd(Result),
            Value
    end.

decode(TupleList) when is_list(TupleList), is_tuple(hd(TupleList)) ->
    {ok, decode_tuplelist(TupleList), []}.

decode_tuplelist(TL) when is_list(TL), is_tuple(hd(TL))->
    {obj, [{a2l(K), decode_tuplelist(V)} || {K, V} <- TL]};
decode_tuplelist(Str) when is_list(Str), is_integer(hd(Str)) ->
    list_to_binary(to_utf8(Str));
decode_tuplelist(List) when is_list(List), is_list(hd(List)) ->
    [decode_tuplelist(X) || X <- List];
decode_tuplelist(true) -> true;
decode_tuplelist(false) -> false;
decode_tuplelist(null) -> null;
decode_tuplelist([]) -> [];
decode_tuplelist(Str) when is_atom(Str) ->
    list_to_binary(to_utf8(atom_to_list(Str)));
decode_tuplelist(Str) when is_binary(Str) -> Str;
decode_tuplelist(Int) when is_integer(Int) -> Int;
decode_tuplelist(_) ->
    [].



%% @spec to_utf8(Str) -> Bytes::utf8_chardata()
%% where
%%        Str = string() | binary()
%% @doc 将unicode字符串转换为UTF-8编码,Str可能包含已编码的字符，该函数将忽略这些字符
%% 请参考:
%%     http://www.ietf.org/rfc/rfc3629.txt
%%     RFC 3629: "UTF-8, a transformation format of ISO 10646".
to_utf8(Str) when is_binary(Str) ->
    to_utf8(binary_to_list(Str));
to_utf8(Str) when is_list(Str) ->
    to_utf8_1(Str, []).

to_utf8_1([], Acc) -> lists:reverse(Acc);
to_utf8_1([C|T], Acc) when C < 16#80 ->
    %% Plain Ascii character.
    to_utf8_1(T, [C | Acc]);

%% Notice: The following check only applicable to chars <= 16#FF
%% If the char sequence is already UTF8, keep it, otherwise, convert to UTF8
to_utf8_1([C1,C2|T], Acc) when C1 =< 16#FF, C2 =< 16#FF, C1 band 16#E0 =:= 16#C0,
C2 band 16#C0 =:= 16#80 ->
    case ((C1 band 16#1F) bsl 6) bor (C2 band 16#3F) of
        C when C >= 16#80 ->
            to_utf8_1(T, [C2 | [C1 | Acc]]);
        _ ->
            %% Bad range.
            to_utf8_1([C2 | T], concat_as_utf8(C1, Acc))
    end;
to_utf8_1([C1,C2,C3|T], Acc) when C1 =< 16#FF, C2 =< 16#FF, C3 =< 16#FF, C1 band 16#F0 =:= 16#E0,
C2 band 16#C0 =:= 16#80,
C3 band 16#C0 =:= 16#80 ->
    case ((((C1 band 16#0F) bsl 6) bor (C2 band 16#3F)) bsl 6) bor (C3 band 16#3F) of
        C when C >= 16#800 ->
            to_utf8_1(T, [C3 | [C2 | [C1 | Acc]]]);
        _ ->
            %% Bad range.
            to_utf8_1([C3 | [C2 | T]], concat_as_utf8(C1, Acc))
    end;
to_utf8_1([C1,C2,C3,C4|T], Acc) when C1 =< 16#FF, C2 =< 16#FF, C3 =< 16#FF, C4 =< 16#FF, C1 band 16#F8 =:= 16#F0,
C2 band 16#C0 =:= 16#80,
C3 band 16#C0 =:= 16#80,
C4 band 16#C0 =:= 16#80 ->
    case ((((((C1 band 16#0F) bsl 6) bor (C2 band 16#3F)) bsl 6) bor (C3 band 16#3F)) bsl 6) bor (C4 band 16#3F) of
        C when C >= 16#10000 ->
            to_utf8_1(T, [C4 | [C3 | [C2 | [C1 | Acc]]]]);
        _ ->
            %% Bad range.
            to_utf8_1([C4 | [C3 | [C2 | T]]], concat_as_utf8(C1, Acc))
    end;
%% All chars >= 16#80 should be converted to utf8.
to_utf8_1([C|T], Acc) when C >= 16#80 ->
    to_utf8_1(T, concat_as_utf8(C, Acc));
to_utf8_1([C1,C2|T], Acc) when C2 >= 16#80 ->
    to_utf8_1(T, concat_as_utf8(C2, [C1 | Acc]));
to_utf8_1([C1,C2,C3|T], Acc) when C3 >= 16#80 ->
    to_utf8_1(T, concat_as_utf8(C3, [C2 | [C1 | Acc]]));
to_utf8_1([C1,C2,C3,C4|T], Acc) when C4 >= 16#80 ->
    to_utf8_1(T, concat_as_utf8(C4, [C3 | [C2 | [C1 | Acc]]]));
%% Bad range.
to_utf8_1([H|T], Acc) ->
    to_utf8_1(T, concat_as_utf8(H, Acc)).

%% @spec concat_as_utf8(C::char(), Acc::list()) -> [byte()]
%% @doc 将unicode字符转换为UTF-8编码的list(),然后拼接到指定字符串的头部，
%%      如果C不是unicode字符，那么原样返回指定的字符串。
concat_as_utf8(C, Acc) when is_integer(C), C >= 0 ->
    if  C < 128 ->
            %% 0yyyyyyy
            [C | Acc];
        C < 16#800 ->
            %% 110xxxxy 10yyyyyy
            B1 = 16#C0 + (C bsr 6),
            B2 = 128 + (C band 16#3F),
            [B2 | [B1 | Acc]];
        C < 16#10000 ->
            %% 1110xxxx 10xyyyyy 10yyyyyy
            if  C < 16#D800; C > 16#DFFF, C < 16#FFFE ->
                    B1 = 16#E0 + (C bsr 12),
                    B2 = 128 + ((C bsr 6) band 16#3F),
                    B3 = 128 + (C band 16#3F),
                    [B3 | [B2 | [B1 | Acc]]];
                true ->
                    Acc
            end;
        C < 16#200000 ->
            %% 11110xxx 10xxyyyy 10yyyyyy 10yyyyyy
            B1 = 16#F0 + (C bsr 18),
            B2 = 128 + ((C bsr 12) band 16#3F),
            B3 = 128 + ((C bsr 6) band 16#3F),
            B4 = 128 + (C band 16#3F),
            [B4 | [B3 | [B2 | [B1 | Acc]]]];
        C < 16#4000000 ->
            %% 111110xx 10xxxyyy 10yyyyyy 10yyyyyy 10yyyyyy
            B1 = 16#F8 + (C bsr 24),
            B2 = 128 + ((C bsr 18) band 16#3F),
            B3 = 128 + ((C bsr 12) band 16#3F),
            B4 = 128 + ((C bsr  6) band 16#3F),
            B5 = 128 + (C band 16#3F),
            [B5 | [B4 | [B3 | [B2 | [B1 | Acc]]]]];
        C < 16#80000000 ->
            %% 1111110x 10xxxxyy 10yyyyyy 10yyyyyy 10yyyyyy 10yyyyyy
            B1 = 16#FC + (C bsr 30),
            B2 = 128 + ((C bsr 24) band 16#3F),
            B3 = 128 + ((C bsr 18) band 16#3F),
            B4 = 128 + ((C bsr 12) band 16#3F),
            B5 = 128 + ((C bsr  6) band 16#3F),
            B6 = 128 + (C band 16#3F),
            [B6 | [B5 | [B4 | [B3 | [B2 | [B1 | Acc]]]]]];
        true ->
            Acc
    end.



%% @spec (json()) -> [byte()]
%%
%% @doc 将json格式数据转换成utf-8编码字符串。
encode(X) ->
    unicode_encode({'utf-8', encode_noauto(X)}).

%% @private
%% @spec (json()) -> string()
%%
%% @doc Encodes the JSON value supplied into raw Unicode codepoints.
%%
%% The resulting string may contain codepoints with value >=128. You
%% can use {@link unicode_encode/1} to UTF-encode the results, if
%% that's appropriate for your application.
%%
%% During encoding, atoms and binaries are accepted as keys of JSON
%% objects (type {@link jsonkey()}) as well as the usual strings
%% (lists of character codepoints).
encode_noauto(X) ->
    lists:reverse(encode_noauto(X, [])).

%% @private
%% @spec (json(), string()) -> string()
%%
%% @doc As {@link encode_noauto/1}, but prepends <i>reversed</i> text
%% to the supplied accumulator string.
encode_noauto(true, Acc) ->
    "eurt" ++ Acc;
encode_noauto(false, Acc) ->
    "eslaf" ++ Acc;
encode_noauto(null, Acc) ->
    "llun" ++ Acc;
encode_noauto(Str, Acc) when is_binary(Str) ->
    Codepoints = xmerl_ucs:from_utf8(Str),
    quote_and_encode_string(Codepoints, Acc);
encode_noauto(Str, Acc) when is_atom(Str) ->
    quote_and_encode_string(atom_to_list(Str), Acc);
encode_noauto(Num, Acc) when is_number(Num) ->
    encode_number(Num, Acc);
encode_noauto({obj, Fields}, Acc) ->
    "}" ++ encode_object(Fields, "{" ++ Acc);
encode_noauto(Arr, Acc) when is_list(Arr) ->
    "]" ++ encode_array(Arr, "[" ++ Acc).

encode_object([], Acc) ->
    Acc;
encode_object([{Key, Value}], Acc) ->
    encode_field(Key, Value, Acc);
encode_object([{Key, Value} | Rest], Acc) ->
    encode_object(Rest, "," ++ encode_field(Key, Value, Acc)).

encode_field(Key, Value, Acc) when is_binary(Key) ->
    Codepoints = xmerl_ucs:from_utf8(Key),
    encode_noauto(Value, ":" ++ quote_and_encode_string(Codepoints, Acc));
encode_field(Key, Value, Acc) when is_atom(Key) ->
    encode_noauto(Value, ":" ++ quote_and_encode_string(atom_to_list(Key), Acc));
encode_field(Key, Value, Acc) when is_list(Key) ->
    encode_noauto(Value, ":" ++ quote_and_encode_string(Key, Acc)).

encode_array([], Acc) ->
    Acc;
encode_array([X], Acc) ->
    encode_noauto(X, Acc);
encode_array([X | Rest], Acc) ->
    encode_array(Rest, "," ++ encode_noauto(X, Acc)).

quote_and_encode_string(Str, Acc) ->
    "\"" ++ encode_string(Str, "\"" ++ Acc).

encode_string([], Acc) ->
    Acc;
encode_string([$" | Rest], Acc) ->
    encode_string(Rest, [$", $\\ | Acc]);
encode_string([$\\ | Rest], Acc) ->
    encode_string(Rest, [$\\, $\\ | Acc]);
encode_string([X | Rest], Acc) when X < 32 orelse X > 127 ->
    encode_string(Rest, encode_general_char(X, Acc));
encode_string([X | Rest], Acc) ->
    encode_string(Rest, [X | Acc]).

%% @private
%% @spec (EncodingAndCharacters::{Encoding, [char()]}) -> [byte()]
%% where Encoding = 'utf-32' | 'utf-32be' | 'utf-32le' | 'utf-16' |
%%                  'utf-16be' | 'utf-16le' | 'utf-8'
%%
%% @doc Encodes the given characters to bytes, using the given Unicode encoding.
%%
%% For convenience, we supply a partial inverse of unicode_decode; If
%% a BOM is requested, we more-or-less arbitrarily pick the big-endian
%% variant of the encoding, since big-endian is network-order. We
%% don't support UTF-8 with BOM here.
unicode_encode({'utf-32', C}) -> [0,0,254,255|xmerl_ucs:to_ucs4be(C)];
unicode_encode({'utf-32be', C}) -> xmerl_ucs:to_ucs4be(C);
unicode_encode({'utf-32le', C}) -> xmerl_ucs:to_ucs4le(C);
unicode_encode({'utf-16', C}) -> [254,255|xmerl_ucs:to_utf16be(C)];
unicode_encode({'utf-16be', C}) -> xmerl_ucs:to_utf16be(C);
unicode_encode({'utf-16le', C}) -> xmerl_ucs:to_utf16le(C);
unicode_encode({'utf-8', C}) -> xmerl_ucs:to_utf8(C).

encode_number(Num, Acc) when is_integer(Num) ->
    lists:reverse(integer_to_list(Num), Acc);
encode_number(Num, Acc) when is_float(Num) ->
    lists:reverse(float_to_list(Num), Acc).

encode_general_char(8, Acc) -> [$b, $\\ | Acc];
encode_general_char(9, Acc) -> [$t, $\\ | Acc];
encode_general_char(10, Acc) -> [$n, $\\ | Acc];
encode_general_char(12, Acc) -> [$f, $\\ | Acc];
encode_general_char(13, Acc) -> [$r, $\\ | Acc];
encode_general_char(X, Acc) when X > 127 -> [X | Acc];
encode_general_char(X, Acc) ->
    %% FIXME currently this branch never runs.
    %% We could make it configurable, maybe?
    Utf16Bytes = xmerl_ucs:to_utf16be(X),
    encode_utf16be_chars(Utf16Bytes, Acc).

encode_utf16be_chars([], Acc) ->
    Acc;
encode_utf16be_chars([B1, B2 | Rest], Acc) ->
    encode_utf16be_chars(Rest, [
        hex_digit((B2) band 16#F),
        hex_digit((B2 bsr 4) band 16#F),
        hex_digit((B1) band 16#F),
        hex_digit((B1 bsr 4) band 16#F),
        $u,
        $\\ | Acc]).

%% @private
%% @spec (Nibble::integer()) -> char()
%% @doc Returns the character code corresponding to Nibble.
%%
%% Nibble must be >=0 and =&lt;16.
hex_digit(0) -> $0;
hex_digit(1) -> $1;
hex_digit(2) -> $2;
hex_digit(3) -> $3;
hex_digit(4) -> $4;
hex_digit(5) -> $5;
hex_digit(6) -> $6;
hex_digit(7) -> $7;
hex_digit(8) -> $8;
hex_digit(9) -> $9;
hex_digit(10) -> $A;
hex_digit(11) -> $B;
hex_digit(12) -> $C;
hex_digit(13) -> $D;
hex_digit(14) -> $E;
hex_digit(15) -> $F.

to_integer(P) ->
    case P of
        L when is_list(L) ->
            list_to_integer(L);
        I when is_integer(I) ->
            I;
        B when is_binary(B) ->
            list_to_integer(binary_to_list(B));
        A when is_atom(A) ->
            list_to_integer(atom_to_list(A));
        true ->
            P
    end.
