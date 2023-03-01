defmodule KaizeVotes.Constants do
  @moduledoc false

  @spec login_url() :: String.t()
  def login_url, do: "https://kaize.io/login"

  @spec remember_login() :: String.t()
  def remember_login, do: "on"
end
