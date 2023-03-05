import Config

config :logger, :console, format: "$date $time $metadata[$level] $message\n"

config :kaize_votes, :http_client, KaizeVotes.Http

config_env_path = Path.expand("./#{config_env()}.exs", __DIR__)

if File.exists?(config_env_path) do
  import_config(config_env_path)
end
