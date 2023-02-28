defmodule KaizeVotes.Env do
  @moduledoc false

  @spec http_client() :: module()
  def http_client do
    fetch_env!(:http_client)
  end

  @spec fetch_env!(atom()) :: any()
  def fetch_env!(value) do
    __MODULE__
    |> Application.get_application()
    |> Application.fetch_env!(value)
  end
end
