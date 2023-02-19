import Config

config :logger, :console,
  format: "$date $time $metadata[$level] $message\n"
