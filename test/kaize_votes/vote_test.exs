defmodule KaizeVotes.VoteTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest KaizeVotes.Vote

  alias KaizeVotes.Html
  alias KaizeVotes.TestHelper, as: H
  alias KaizeVotes.Vote

  def vote_value(doc) do
    Html.attribute(doc, ~s{form.proposal-vote-form input[name="vote"]}, "value")
  end

  setup_all context do
    doc = H.doc("proposal.html")

    new_context = Map.put(context, :doc, doc)

    {:ok, new_context}
  end

  defmodule HttpVoteUpMock do
    @moduledoc false

    def post(url, data) do
      assert url == "https://kaize.io/proposal/161282-63f8b8f1567f6/save-vote"
      assert data.vote == "up"
    end
  end

  describe "vote_up/2" do
    @tag :capture_log
    test "changes form value", %{doc: doc} do
      value =
        doc
        |> Vote.up(HttpVoteUpMock)
        |> vote_value()

      assert value == "up"
    end
  end

  defmodule HttpVoteDownMock do
    @moduledoc false

    def post(url, data) do
      assert url == "https://kaize.io/proposal/161282-63f8b8f1567f6/save-vote"
      assert data.vote == "down"
    end
  end

  describe "vote_down/2" do
    @tag :capture_log
    test "changes form value", %{doc: doc} do
      value =
        doc
        |> Vote.down(HttpVoteDownMock)
        |> vote_value()

      assert value == "down"
    end
  end
end
