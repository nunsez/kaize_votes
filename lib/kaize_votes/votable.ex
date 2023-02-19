defmodule KaizeVotes.Votable do
  @moduledoc false

  alias KaizeVotes.Html

  @spec can_vote_down?(Html.document()) :: boolean()
  def can_vote_down?(document) do
    can_vote?(document) and enough_down_votes?(document)
  end

  @vote_down_threshold 3

  @spec enough_down_votes?(Html.document()) :: boolean()
  defp enough_down_votes?(document) do
    count =
      document
      |> Html.find(".proposal-user-vote .choice.down")
      |> Enum.count()

    count >= @vote_down_threshold
  end

  @spec can_vote_up?(Html.document()) :: boolean()
  def can_vote_up?(document) do
    can_vote?(document) and enough_up_votes?(document)
  end

  @vote_up_threshold 3

  defp enough_up_votes?(document) do
    count =
      document
      |> Html.find(".proposal-user-vote .choice.up")
      |> Enum.count()

    count >= @vote_up_threshold
  end

  @spec can_vote?(Html.document()) :: boolean()
  defp can_vote?(document) do
    selector = ~s{form.proposal-vote-form input[name="vote"]}
    input_value = Html.attribute(document, selector, "value")

    input_value == ""
  end
end
