%% @author 
%% @doc @todo Add description to ${channel}.

-module(${channel}).

-include("ewp.hrl").
%% ====================================================================
%% API functions
%% ====================================================================
-compile([export_all]).

%% ----------------------------------------------------
%%         callback template for channel adapt
%% ----------------------------------------------------
'${tranCode}'(TranCode, Channel) ->

    Response=
        ewp_adapter:invoke_procedure("${procedure}","${adapter}",[{'tranCode', TranCode}]),

    CsKey = ewp_channel_util:channel_adapter_cs_key(Channel, TranCode),

    ewp_channel_util:render(CsKey, [], Response).

%% ====================================================================
%% Internal functions
%% ====================================================================

