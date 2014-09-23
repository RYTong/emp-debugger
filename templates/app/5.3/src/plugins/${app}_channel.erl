%% Copyright (c) 2014-2015 Beijing RYTong Information Technologies, Ltd.
%% All rights reserved.
%%
%% No part of this source code may be copied, used, or modified
%% without the express written consent of RYTong.
%%
%% @doc
%% @doc ewp plugin

-module(${app}_channel).

%%
%% Include files
%%

-behavior(generic_channel).

-include("yaws_api.hrl").
-include("ewp.hrl").
-include("${app}.hrl").

-export([transform/3,
         gen_query_request/2
        ]).

-export([role_auth/2,
         get_cache_mapping/0,
         list_collection_items/2]).

-export([test_page/0,
         card_to_card/0]).


-define(APP_SESSION_COOKIE, "ebanksession").

%% callback function :: transform/3

%% 回调函数结构说明：
%% 在transform内处理项目级别的定制，即所有业务通用的定制逻辑；
%% 而channel级别的定制则分发到与channel id同名的模块处理，具体见流程中的注释
%% channel定制模块应返回 {XmlList, TupleList}作为模板输入

%% 参数 Res格式为 [{res, tuplelist()}]或者{http_response, Headers, Body}
%% [{res, ...}] 为经过generic_channel:handle_internal_form处理之后的 客户端相关参数
%% {http_response, Headers, Body} 为远程服务器的返回

transform(Format, Res, Channel) ->
    ?app_trace ("app/channel: transform  start!",[]),

    ?channel_error ("channel transform:log test: channel_error",[]),
    ?report_error ("report transform:log test:report error",?MODULE, []),
    ?module_error ("module transform:log test:module error",[]),
    ?app_error ("app transform:log test:app error",[]),

    ?channel_info ("channel transform:log test: channel info",[]),
    ?report_info ("report transform:log test:report info",?MODULE,[]),
    ?module_info ("module transform:log test:module info",[]),
    ?app_info ("app transform:log test:app info",[]),

    ?channel_debug ("channel transform:log test: channel debug",[]),
    ?report_debug ("report transform:log test:report debug",?MODULE,[]),
    ?module_debug ("module transform:log test:module debug",[]),
    ?app_debug ("app transform:log test:app debug",[]),

    ?channel_trace ("channel transform:log test: channel trace",[]),
    ?report_trace ("report transform:log test:report trace",?MODULE,[]),
    ?module_trace ("module transform:log test:module trace",[]),
    ?app_trace ("app transform:log test:app trace",[]),

    TranCode = ?param("tranCode"),
    ?cpu_begin(module_entrance),
    CsKey = ewp_channel_util:channel_run_cs_key(Channel, TranCode, Format),
    ?app_trace ("app/channel: transform channelID:",[{channelid, o(Channel, id)}]),
    ?app_trace ("app/channel: transform cskey:",[{cskey, CsKey}]),
    ?ewp_log("the cskey is ~p~n",[CsKey]),

    %% 如果有channel级别的定制，发往与channel id同名的module处理，处理方法为
    %% $channel_id:transfrom_$trancode(Channel, TupleList)
    %% 例如channel id为ebank_zhcx, trancode 为 start，则处理方法为
    %% ebank_zhcx:transform_start(Channel, TupleList)
    %% 其中TupleList为 [{res, ...}] 或者经过xml_eng:xml_to_term转化为tupleList结构的xml
    %% 可供过xml_eng:xpath_term取值（这样做是为了防止模板人员反复解析xml）
    %% 在channel定制模块中的xml解析和取值可以使用该方法
    %% 注意：此处不要添加channel级别的定制逻辑，否则会导致代码可读性和可维护性降低
    {Xml, TupleList} = case process_channel(transform, Channel, TranCode, Res, fun process_res/1) of
                           undefined ->
                               return(Res);
                           Val = {_, _} ->
                               Val
                       end,
    {CsKey, Xml, TupleList}.


return([{res, _}]= Res) ->
    {[], Res};
return({http_respones, _Headers, Body}) ->
    {Body, []}.

process_res([{res, _}]= Res) ->
    Res;
process_res({http_response, _Headers, Body}) ->
    xml_eng:xml_to_term(Body).

func(undefined, undefined) ->
    throw("can't delegate to undefined callback and trancode");
func(undefined, TranCode) when is_list(TranCode) ->
    list_to_atom(TranCode);
func(Callback, undefined) when is_atom(Callback) ->
    Callback;
func(Callback, TranCode) when is_atom(Callback), is_list(TranCode) ->
    list_to_atom(lists:concat([Callback, "_", TranCode])).


process_channel(Callback, Channel, TranCode, Arg) ->
    process_channel(Callback, Channel, TranCode, Arg, undefined).

process_channel(Callback, Channel, TranCode, Arg, ArgFun) ->
    Module = case o(Channel, id) of
                 Id when is_list(Id) ->
                     list_to_atom(Id);
                 Atom when is_atom(Atom) ->
                     Atom
             end,
    Func = func(Callback, TranCode) ,
    ?ewp_log("Func is ....~p~n",[Func]),
    case code:ensure_loaded(Module) of
        {module, _} ->
            case erlang:function_exported(Module, Func, 2) of
                true ->
                    NewArg = case ArgFun of
                                 undefined -> Arg;
                                 _ -> ArgFun(Arg)
                             end,
                    ?app_trace ("app/channel: delegate channel request to :",[{module, Module},
                                                                              {function, Func},
                                                                              {arg, NewArg}]),
                    Module:Func(Channel, NewArg);
                _ ->
                    undefined
            end;
        _ ->
            undefined
    end.

%% callback function
%% 这个函数通常被 channel/list和channel/run等公用，
%% 所以我们把调用者的名称作为参数，作为可能的定制逻辑的判断条件。
%% 函数本身用来验证session和用户身份

%% channel run流程
%% 如果channel run和channel list认证逻辑完全相同，可以去掉该分支
role_auth(A, {run, Channel}) ->
    %% 如果需要为channel的每一个trancode定制逻辑，则在channel模块中
    %% 实现 role_auth_'$trancode'方法，或者为整个channel实现role_auth方法
    %% 我们认为channel的认证逻辑在每个trancode处应该是一致的，所以
    %% 将trancode赋值为undefiend
    TranCode = undefined,
    %% 如果需要为trancode定制认证逻辑，则打开下面的代码
    %% TranCode = ?param("tranCode"),
    case process_channel(role_auth, Channel, TranCode, A) of
        undefined ->
            %% 通channel/list认证逻辑相同
            role_auth(A, list);
        Res ->
            Res
    end;
role_auth(A, _FunName) ->
    ?app_trace("app/role_auth: start!", []),
    %% 可以根据需求选择调用 session_service:verify/1 verify_login/1
    %% verfiy_login除验证session有效外还验证用户是否登陆
    session_service:verify(A),
    %% 验证session通过之后,可通过?session(Name)获取session中的相应数据
    %% UserId = ?session(user_id),
    %% User = ewp_store:lookup_f(UserId),
    User = undefined,
    {true, User}.

%% callback function
%% channel/list 的回调入口
%% 修改collection返回的数据项值
%% 修改channel返回的数据项值
list_collection_items(Format, User) ->
    ?app_trace ("app/list_collection_items start", []),
    Param_Type = ?param("type"),
    ?ewp_log("Param_Type is =========~p~n",[Param_Type]),
    {Id, Type} = case ?param("id") of
                     undefined->
                         case User of
                             undefined -> throw("no collection id");
                             _ ->
                                 {o(User,favorite_collection_id),collections}
                         end;
                     CollectionId ->
                         ?app_trace ("app/list_ collection_items:CollectionId:",
                                     [{collectionid, CollectionId}]),
                         NewType = case Param_Type of
                                       undefined ->
                                           channels;
                                       _ ->
                                           list_to_atom(Param_Type)
                                   end,
                         {CollectionId,NewType}
                 end,

    ?cpu_begin(list_collection_items),
    Items = ewp_channel_util:list_collection_items(Id, Type),
    ?cpu_end(list_collection_items),

    ?app_trace ("app/list_collection_items items : ", [{collection_items, Items}]),

    ?cpu_begin(collection_to_cs_tuplelist),
    Input = collection_to_cs_tuplelist(Format, Type, Items)++[{collection_id ,Id}],
    ?cpu_end(collection_to_cs_tuplelist),

    %% 项目可根据需要在标准的collection属性之外，添加其他的key-value作为模板输入
%%     AppendedInput = append_params(Input),
    CsKey = get_cskey(Type, Format),
    ?app_trace ("app/list_collection_items over ", [{cskey,CsKey},{input,Input}]),
    _Page = cs_api:render(CsKey, Input),
    {CsKey, Input}.

%%根据collection菜单或者channel菜单返回不同的cs文件名称
%%collections为ebank_list_i.cs
%%channels为ebank_channels_i.cs
get_cskey(collections,Format) ->
    lists:concat([?param(app), "_list_", Format]);
get_cskey(channels,Format) ->
    lists:concat([?param(app), "_channels_", Format]).

%% 根据存储collection获取各个collection对应json数据中需要选项
%% 由于Items返回只有 id ,app ,name ,url ,user_id ,type ,state
%% 例如：{collection,"tranfer_remit","ebank",[232,189,172,232,180,166,230,177,135,230,172,190],
%%     undefined,"tranfer1",0,1}
%% 现在变更增加collection字段涉及改造产品太多部分代码，所以将非必须使用字段作为app中需添加字段
%% 现在代码中将user_id作为菜单图片的名称字段，其实url在标准银行框架中也可以不需要可以用作菜单功能描述等说明。
collection_to_cs_tuplelist(_Format, collections, Items) ->
    ?ewp_log("Items is ==========~p~n",[Items]),
    gen_collection_list(Items);

%% 根据存储获取各个channel对应json数据中需要选项
%% 由于Items返回只有 id,app,name,entry,views,props
%% 例如： {channel,"balance_qry","ebank",
%%       [228,189,153,233,162,157,230,159,165,232,175,162],channel_adapter,undefined,
%%       [{method,post},{encrypt_flag,0},{trancode,"mb01"}],1}
%% 将json数据对应需要字段放在props里面然后获取。
collection_to_cs_tuplelist(_Format,channels, Items) ->
    ?ewp_log("Items is ==========~p~n",[Items]),
    gen_channel_list(Items).

%% @doc Generate cs format input for collection list.
gen_collection_list(Collections) ->
    [gen_collection(Collection)||Collection<-Collections].

%% @doc Generate cs format input for single channel.
gen_collection(Collection) ->
    {collection, [{id, o(Collection, id)},
                  {name, o(Collection, name)},
                  {menu_img,lists:concat([o(Collection,user_id),".png"])},
                  {url,
                   case o(Collection, url) of
                       undefined ->
                           lists:concat([ewp_yaws_util:get_host(),"/channel/list?id=",o(Collection, id)]);
                       [] ->
                           lists:concat([ewp_yaws_util:get_host(),"/channel/list?id=",o(Collection, id)]);
                       Url ->
                           Url
                   end}
                 ]}.

%% @doc Generate cs format input for channel list.
gen_channel_list(Channels) ->
    [gen_channel(Channel)||Channel<-Channels].

%% @doc Generate cs format input for single channel.
gen_channel(Channel) ->
    Props = o(Channel,props),
    ?ewp_log("Props is ===============~p~n",[Props]),
    TranCode = o(Props,trancode),
    ?ewp_log("TranCode is ===============~p~n",[TranCode]),
    Channel_desc = o(Props,channel_desc),
    Channel_img = o(Props,channel_img),
    Function_desc = o(Props,function_desc),
    {channel, [{id, o(Channel, id)},
               {name, o(Channel, name)},
               {url, requested_url(Channel)},
               {trancode,TranCode},
               {channel_desc,Channel_desc},
               {channel_img,Channel_img},
               {function_desc,Function_desc},
               {secure, o(Channel, encrypt_flag)}
              ]}.

requested_url(Channel) ->
    Url = o(Channel,url),
    case Url of
        "local://" ++ _Rest ->
            Url;
        _ ->
            requested_url(ewp_params:param(o), o(Channel, encrypt_flag), ewp_str_util:to_list(o(Channel, id)))
    end.
requested_url(wap, 1, Id) ->
    lists:concat([ewp_yaws_util:get_host(), "/channel/run?id=", Id]);
requested_url(_, 1, Id) ->
    lists:concat([ewp_yaws_util:get_host(), "/channel_s/run?id=", Id]);
requested_url(_, 0, Id) ->
    lists:concat([ewp_yaws_util:get_host(), "/channel/run?id=", Id]);
requested_url(_, _Encrypted, _Id) ->
    [].

append_params(Input) ->
    CheckInfo  = ?session("checkInfo"),
    LoginTimes = ?session("loginTimes"),
    _CardList   = ?session("ebankCardList"),
    CustomName = ?session("customerName"),
    CollectionName = ?param("name"),
    %%[CardCSList, FList] = ebank_utils:cardlist_to_cs_params(CardList),
    %%?ewp_log("the card cs list :~p~n", [CardCSList]),
    [{loginTimes, LoginTimes},
     {checkInfo, CheckInfo},
     %%{cardlist, CardCSList},
     {customname, CustomName},
     %%{cardlen, length(CardCSList)},
     %%{firstcard, FList},
     {name, CollectionName}|Input].

%% callback function
%% channel/run 的回调请求函数
%% 拼装远程请求，在这里为远程请求定制详细的参数，header以及HTTP Option
gen_query_request(Channel, Url) ->
    %% 通常我们需要将客户端请求ewp的参数作为请求远程HTTP Server的参数，
    %% 我们需要过滤掉客户端为EWP定制的参数，例如o，app，n等
    AppendedParams = ewp_params:filter_params_to_url(),
    ?app_trace("app/gen_query_request:start !", []),
    Method = o(Channel, method),

    %% 通过 append_params添加请求参数
    NewRequest = append_params(Url, AppendedParams),
    %% If we have saved a session cookie, use it on this server.
    CookieHeader = make_session_cookie_header(),

    %% 通过 append_headers添加请求的HTTP header
    Request1 = append_headers(NewRequest, CookieHeader),

    %% Options 为inet所支持的HTTP Client的Options
    Options = [{body_format, binary}],

    %% 可以在HttpOptions中设置请求的超时，以及HTTP请求的版本，否则会通过ewp_http_client默认指定
    %% 如 [{timeout, 60000}, {version, "HTTP/1.0"}]
    HttpOptions = [],
    ?app_trace("app/gen_query_request: requst:", [{method, Method}, {request, Request1},
                                                   {http_options, HttpOptions}, {options, Options}]),

    %% 第二个参数Requst的格式通常为{Url, Header, ContentType, Body}
    %% 当Channel配置为get方式请求时，为{Url, Header}
    Return = {Method, Request1, HttpOptions, Options},

    case process_channel(gen_query_request, Channel, ?param("tranCode"), Return) of
        undefined ->
            Return;
        Res ->
            Res
    end.

make_session_cookie_header() ->
    case ?session(?APP_SESSION_COOKIE) of
        undefined -> [];
        EbankCookie -> [{"cookie", EbankCookie}]
    end.

append_params({Url, Headers, ContentType, []}, String) ->
    {Url, Headers, ContentType, list_to_binary(String)};
append_params({Url, Header, ContentType, Body}, String) ->
    NewBody = case is_binary(Body) of
                  true ->
                      binary_to_list(Body) ++ "&" ++ String;
                  _ ->
                      Body++"&"++ String
              end,
    {Url, Header, ContentType, list_to_binary(NewBody)};
append_params({Url, Header}, String) ->
    Char = join_char(Url),
    {lists:concat([Url, Char, String]), Header};
append_params(Url, String) ->
    Char = join_char(Url),
    {lists:concat([Url, Char, String]), []}.


append_headers({Url, Headers, ContentType, Body}, List) ->
    {Url, Headers ++ List, ContentType, Body};
append_headers({Url, Headers}, List) ->
    {Url, Headers ++ List};
append_headers(Url, List) ->
    {Url, List}.

join_char(Url) ->
    case string:chr(Url, $?) of
        true ->
            "&";
        _ ->
            "?"
    end.



%% 下面是缓存页面接口 get_cached_page 所用的回调函数

get_cache_mapping() ->
    [{test_page, 0},
     {card_to_card, 1}].

test_page() ->
    ewp_render_util:render_text("this is a test page").
card_to_card() ->
    ewp_render_util:render_xml("xml for card to card").
