%%----------------------------------------------------------------------
%% ${app} specific attributes
%%----------------------------------------------------------------------

-define(APP, "${app}").

%% Marco to get parameters in app conf files.

-define(app_conf(Key), ?app_conf(Key, undefined)).
-define(app_conf(Key, Default), ewp_conf_util:get_app_conf_value(?APP, Key, Default)).

-define(save_remote(XmlList), put(remote_res, XmlList)).
-define(get_remote(), get(remote_res)).

-include("ewp.hrl").
-include("${app}_error.hrl").

%%----------------------------------------------------------------------
%% End of ${app} specific attributes
%%----------------------------------------------------------------------
