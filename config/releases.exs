import Config

config :agile, port: String.to_integer(System.fetch_env!("PORT"))
config :agile, games: [{PointingPoker, "pointing_poker"}]
