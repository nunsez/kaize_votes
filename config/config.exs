import Config

config :logger, :console,
  format: "$date $time $metadata[$level] $message\n"

config :kaize_votes, :http_client, KaizeVotes.Http


config_env_file = "#{config_env()}.exs"

if File.exists?(config_env_file) do
  import_config(config_env_file)
end
