%% Copyright (c) 2009-2010 Beijing RYTong Information Technologies, Ltd.
%% All rights reserved.
%%
%% No part of this source code may be copied, used, or modified
%% without the express written consent of RYTong.
%%
%% @doc
%% @doc Main entrance to the entire ewp application.

-module(${app}_bootstrap).

-include("${app}.hrl").

-export([start/1,
         stop/0]).


%% callbacks defined for app_manager to start or stop the app.
start(#appl{env = Env,
            dir = AppDir}) ->
    %% @notic 如果需要使用utf
    %%     ewp_adapter_server:start(),
    %%     ewp_adapter:load_conf("config/adapter.conf"),
    load_error_conf(),
    ok.

stop() ->
    ok.

load_error_conf() ->
    error_code_service:load_from_file(${app}, "config/err_code.conf").
