import Config

if config_env() == :prod do
  config :kaize_votes, :email, System.fetch_env!("KAIZE_EMAIL")
  config :kaize_votes, :password, System.fetch_env!("KAIZE_PASSWORD")
end
