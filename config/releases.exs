import Config

config :agile, port: String.to_integer(System.fetch_env!("PORT"))
