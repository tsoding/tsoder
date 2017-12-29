-module(memigrate).
-export([migrate/1]).

create_memigrate_schema_table() ->
    error_logger:info_msg("Preparing memigrate_schema table..."),
    SchemaExists = not lists:member(memigrate_schema, mnesia:system_info(tables)),
    if
        SchemaExists -> error_logger:info_msg("Could not find memigrate_schema table. Creating..."),
                        mnesia:create_table(memigrate_schema, [{disc_copies, [node()]}]);
        true -> error_logger:info_msg("Found memigrate_schema table")
    end,
    mnesia:wait_for_tables([memigrate_schema], 5000),
    error_logger:info_msg("memigrate_schema table is ready").

is_applied_migration({Id, _}) ->
    {atomic, Applied} = mnesia:transaction(
                          fun() ->
                                  case mnesia:read(memigrate_schema, Id, write) of
                                      [] -> false;
                                      [{memigrate_schema, Id, true}] -> true
                                  end
                          end),
    Applied.

validate_unapplied_migrations(Migrations) ->
    Validated = lists:all(
                  fun (Migration) -> not is_applied_migration(Migration) end,
                  Migrations),
    if
        Validated -> Migrations;
        true -> erlang:error(inconsistent_migrations)
    end.

validate_unique_ids(Migrations) ->
    MigrationsCount = length(Migrations),
    UniqueIdCount = length(
                      lists:usort(
                        lists:map(
                          fun ({Id, _}) -> Id end,
                          Migrations))),
    Validated = MigrationsCount == UniqueIdCount,
    if
        Validated -> Migrations;
        true -> erlang:error(id_duplicates)
    end.

unapplied_migrations(Migrations) ->
    validate_unapplied_migrations(
      lists:dropwhile(
        fun is_applied_migration/1,
        validate_unique_ids(
          Migrations))).

apply_migration({Id, MigrationF}) ->
    ok = MigrationF(),
    error_logger:info_report([applying_migration,
                              {id, Id}]),
    mnesia:transaction(
      fun() ->
              mnesia:write({memigrate_schema, Id, true})
      end).

migrate(Migrations) ->
    create_memigrate_schema_table(),
    lists:foreach(
      fun apply_migration/1,
      unapplied_migrations(Migrations)).
