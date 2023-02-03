defmodule KaizeVotes.Json do
  @moduledoc false

  @spec parse(String.t()) :: any()
  def parse(json) do
    Jason.decode!(json)
  end

  @spec generate(any()) :: String.t()
  def generate(term) do
    Jason.encode!(term)
  end
end
