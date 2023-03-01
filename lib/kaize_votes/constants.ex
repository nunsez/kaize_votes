defmodule KaizeVotes.Constants do
  @moduledoc false

  @spec login_url() :: String.t()
  def login_url, do: "https://kaize.io/login"

  @spec remember_login() :: String.t()
  def remember_login, do: "on"

  @spec vote_up() :: String.t()
  def vote_up, do: "up"

  @spec vote_down() :: String.t()
  def vote_down, do: "down"
end
