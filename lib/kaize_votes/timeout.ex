defmodule KaizeVotes.Timeout do
  @moduledoc false

  @spec before_vote() :: non_neg_integer()
  def before_vote do
    :timer.seconds(5)
  end

  @spec before_next() :: non_neg_integer()
  def before_next do
    :timer.seconds(2)
  end

  @spec before_login() :: non_neg_integer()
  def before_login do
    :timer.seconds(3)
  end

  @spec wait_new_proposals() :: non_neg_integer()
  def wait_new_proposals do
    :timer.minutes(5)
  end

  @doc """
  Must be at least 1 second
  """
  @spec iteration() :: non_neg_integer()
  def iteration do
    :timer.seconds(1)
  end
end
