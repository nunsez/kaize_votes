import Config

config :logger, :console,
  format: "$date $time $metadata[$level] $message\n"

config :kaize_votes, :http_client, KaizeVotes.Http


import_config("#{config_env()}.exs")
