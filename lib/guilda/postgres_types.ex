Postgrex.Types.define(
  Guilda.PostgresTypes,
  [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions()
)
