defmodule KaizeVotes.Votable do
  @moduledoc false

  alias KaizeVotes.Document
  alias KaizeVotes.Html

  @spec can_vote_down?(Html.document()) :: boolean()
  def can_vote_down?(document) do
    Document.votable?(document) and Document.enough_down_votes?(document)
  end

  @spec can_vote_up?(Html.document()) :: boolean()
  def can_vote_up?(document) do
    Document.votable?(document) and Document.enough_up_votes?(document)
  end
end
