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

  @spec can_next?(Html.document()) :: boolean()
  def can_next?(document) do
    not Document.votable?(document) and
      Document.has_next_url?(document)
  end

  @spec rest_time?(Time.t(), Time.t()) :: boolean()
  def rest_time?(start_work, end_work) do
    not work_time?(start_work, end_work)
  end

  @spec work_time?(Time.t(), Time.t()) :: boolean()
  def work_time?(start_work, end_work) do
    current = NaiveDateTime.utc_now()
    date = NaiveDateTime.to_date(current)
    {:ok, work_start} = NaiveDateTime.new(date, start_work)
    {:ok, work_end} = NaiveDateTime.new(date, end_work)

    NaiveDateTime.compare(current, work_start) == :gt and
      NaiveDateTime.compare(current, work_end) == :lt
  end
end
