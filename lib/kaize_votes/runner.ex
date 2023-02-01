defmodule KaizeVotes.Runner do
  alias KaizeVotes.CookieStore

  @spec call :: any()
  def call do
    CookieStore.get() |> IO.inspect()
  end
end
