%% Copyright (c) 2009-2010 Beijing RYTong Information Technologies, Ltd.
%% All rights reserved.
%%
%% No part of this source code may be copied, used, or modified
%% without the express written consent of RYTong.
%%
%% @doc
%% @doc Main entrance to the entire ewp application.

-module(${app}_bootstrap).

-include("ewp.hrl").
-include("${app}.hrl").

-export([start/1,
         stop/0]).



%% callbacks defined for app_manager to start or stop the app.

start(#appl{env = _Env, dir = _AppDir}) ->
    ok.

stop() ->
    ok.

