%% Copyright (c) 2009-2010 Beijing RYTong Information Technologies, Ltd.
%% All rights reserved.
%%
%% No part of this source code may be copied, used, or modified
%% without the express written consent of RYTong.

-module(${app}_security).

-behavior(generic_security).

-include("yaws_api.hrl").
-include("ewp.hrl").
-include("${app}.hrl").

-export([init_content/1]).

-export([decrypt_password/1]).

%%------------------------------------------------------------------------------
%% Callbacks
%%------------------------------------------------------------------------------
%% NOTE：在init_content之前我们并没有在进程字典中保存arg和session，
%% 所以我们不能使用?arg和?session获取参数
init_content(_Arg) ->
    case ?param(o) of
        i ->
	    Prefix = filename:join(?arg("docroot"), ?param(app)),
	    ewp_file_util:read_file(Prefix, "index.xhtml");
        qt ->
            cs_api:render("init_content_qt", []);
        _ ->
            cs_api:render("init_content", [])
    end.

%%------------------------------------------------------------------------------
%% common export functions
%%------------------------------------------------------------------------------
decrypt_password(Password) ->
    CipherState = ?session(cipher_state),
    ?ewp_log("CipherState-----~p~n",[CipherState]),
    decrypt_password(Password, CipherState).


decrypt_password(_, undefined) ->
    {error, ?SESSION_TIMEOUT};
decrypt_password(Password, CipherState) ->
	?ewp_log("Password-----~p~n",[Password]),
    Text = sec_cipher:decrypt_password({Password, CipherState}),
    {ok, Text}.

