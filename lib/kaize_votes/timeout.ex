defmodule KaizeVotes.Timeout do
  @moduledoc false

  @spec before_vote() :: non_neg_integer()
  def before_vote do
    rand(:timer.seconds(5), :timer.seconds(10))
  end

  @spec before_next() :: non_neg_integer()
  def before_next do
    rand(:timer.seconds(3), :timer.seconds(7))
  end

  @spec before_login() :: non_neg_integer()
  def before_login do
    rand(:timer.seconds(10), :timer.seconds(15))
  end

  @spec wait_new_proposals() :: non_neg_integer()
  def wait_new_proposals do
    rand(:timer.minutes(15), :timer.minutes(25))
  end

  @doc """
  Must be at least 1 second
  """
  @spec iteration() :: non_neg_integer()
  def iteration do
    :timer.seconds(1)
  end

  # Returns a random number between min (included) and max (excluded)
  @spec rand(integer(), integer()) :: integer()
  defp rand(min, max) do
    :erlang.floor(min + :rand.uniform() * (max - min))
  end
end
