%% Copyright (c) 2014-2015 Beijing RYTong Information Technologies, Ltd.
%% All rights reserved.
%%
%% No part of this source code may be copied, used, or modified
%% without the express written consent of RYTong.
%%

-module(${app}_migrate).

-behavior(generic_migrate).
%% --------------------------------------------------------------------
%%
%% The main purpose of THIS behavior is to implement
%% the generic workflow of databases' version control.
%% And the app callback module should provide following
%% interfaces to make it work.
%% Especially, it should define both the UP and DOWN
%% actions of one specific database version.
%%
%%
%%
%% The app module should export the following interfaces :
%%
%%     databases()
%%         ==>  [DBName::atom()]
%%         The databases' name that the Callback Module depends on.
%%
%%     version(DBName::atom())
%%         ==>  Version::integer()
%%         The latest migrate version.
%%
%%     migrate(DBName::atom(), Version::integer(), Action::atom()) ->
%%         ==>  ok
%%         The fun that does db operations for db version migration.
%%
%% --------------------------------------------------------------------
%% You can look into the ewp_migrate module for some examples.

%%
%% Include files
%%
-include("ewp.hrl").

-record(${app}_mnesia_test, {
    id,
    name,
    type}).

%%
%% Exported Functions
%%
%% Callbacks
-export([databases/0,
         version/1,
         migrate/3]).

%% FIXME Now they are only for test.
databases() ->
    [mnesia, ewp_development, test].
%%
%% API Functions
%%
%% @doc The latest migrate version
%% @spec version() -> integer()
version(mnesia) ->
    1;
version(test) ->
    1;
version(ewp_development) ->
    1.

%% XXX: The mnesia migration should only be executed by
%% the master node and standalone node, but not by slave
%% nodes.
migrate(mnesia, Version, Action) ->
    ?ewp_log("mnesia migrate ~n", []),
    migrate_mnesia(Version, Action);
migrate(DBName, Version, Action) ->
    ?ewp_log(" ~p migrate ~n", [DBName]),
    migrate_other(DBName, Version, Action).

migrate_mnesia(1, up) ->
    TabDef = [{attributes, record_info(fields, ${app}_mnesia_test)},
        {disc_copies, ?mnesia_nodes()},
        {record_name, ${app}_mnesia_test}],
    do_create_mnesia(${app}_mnesia_test, TabDef),
    NewRecord = #${app}_mnesia_test{id = 1, name = "test", type = "test"},
    mnesia:dirty_write(${app}_mnesia_test, NewRecord);
migrate_mnesia(1, down) ->
    mnesia:delete_table(${app}_mnesia_test).

do_create_mnesia(Name, TabDef) ->
    case mnesia:create_table(Name, TabDef) of
        {atomic, ok} -> ok;
        {aborted, Reason} ->
            ?ewp_err("faild to create mnesia table ~p  for reason :~p~n", [Reason]),
            throw({error, Reason})
    end.

%% create table ${app}_test
migrate_other(ewp_development, 1, up) ->
    SQL = "CREATE TABLE ${app}_development_test (
      id int NOT NULL,
      name varchar(30) NOT NULL,
      type varchar(120) NOT NULL,
      PRIMARY KEY (id)
    ) ENGINE=InnoDB  DEFAULT CHARSET=utf8",
    do_execute_sql(SQL, ewp_development);
%% drop table ${app}_test
migrate_other(ewp_development, 1, down) ->
    do_execute_sql("drop table ${app}_development_test;", ewp_development);

%% create table ${app}_test
migrate_other(test, 1, up) ->
    SQL = "CREATE TABLE ${app}_test (
      id int NOT NULL,
      name varchar(30) NOT NULL,
      type varchar(120) NOT NULL,
      PRIMARY KEY (id)
    ) ENGINE=InnoDB  DEFAULT CHARSET=utf8",
    do_execute_sql(SQL, test);
%% drop table ${app}_test
migrate_other(test, 1, down) ->
    do_execute_sql("drop table ${app}_test;", test).

do_execute_sql(SQL, DBName) ->
    case db_api:execute_sql(SQL, [{pool, DBName}]) of
        {error, Msg} ->
            ?ewp_err("faild to execute SQL: ~p  on database : ~p for reason :~p~n", [SQL, DBName, Msg]),
            throw({error, Msg});
        _ ->
            ok
    end.


%%
%% Local Functions
%%


%%
%% Test Functions

%% unit test
test_config() ->
    [{mnesia, [{mnesia_dir, "./mnesia_migrate_test"}]},
     {databases, [{ewp_development, [{driver, mysql},
                                     {database, "ewp_development"},
                                     {host, "localhost"},
                                     {port, 3306},
                                     {password, "l1ghtp@l3"},
                                     {user, "lpdba"},
                                     {poolsize, 4}]},
                  {test, [{driver, mysql},
                          {database, "test"},
                          {host, "localhost"},
                          {port, 3306},
                          {password, "l1ghtp@l3"},
                          {user, "lpdba"},
                          {poolsize, 4}]}
                 ]}
    ].

migrate_test_() ->
    generic_migrate:standard_test(?MODULE, test_config()).