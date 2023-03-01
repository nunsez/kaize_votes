defmodule KaizeVotes.Env do
  @moduledoc false

  @spec http_client() :: module()
  def http_client do
    fetch_env!(:http_client)
  end

  @spec email() :: String.t()
  def email do
    fetch_env!(:email)
  end

  @spec password() :: String.t()
  def password do
    fetch_env!(:password)
  end

  @spec fetch_env!(atom()) :: any()
  def fetch_env!(value) do
    __MODULE__
    |> Application.get_application()
    |> Application.fetch_env!(value)
  end
end
