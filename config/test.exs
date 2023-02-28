import Config

config :kaize_votes, :email, "test@mail.local"
config :kaize_votes, :password, "p@ssw0rd"

config :kaize_votes, :http_client, KaizeVotes.Http.Mock
