defmodule KaizeVotes.Constants do
  @moduledoc false

  @spec login_url() :: String.t()
  def login_url, do: "https://kaize.io/login"

  @spec proposal_index_url() :: String.t()
  def proposal_index_url, do: "https://kaize.io/proposals"

  @spec remember_login() :: String.t()
  def remember_login, do: "on"

  @spec vote_up() :: String.t()
  def vote_up, do: "up"

  @spec vote_down() :: String.t()
  def vote_down, do: "down"

  @spec vote_down_threshold() :: pos_integer()
  def vote_down_threshold, do: 3

  @spec vote_up_threshold() :: pos_integer()
  def vote_up_threshold, do: 3
end
