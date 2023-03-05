defmodule KaizeVotes.Proposal.NewProposalTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest KaizeVotes.Proposal.NewProposal

  alias KaizeVotes.Proposal
  alias KaizeVotes.Proposal.NewProposal
  alias KaizeVotes.TestHelper, as: H

  describe "call/1" do
    test "returns voted proposal from node" do
      node = H.doc("proposal/proposal_voted.html")
      {:ok, proposal} = NewProposal.call(node)

      assert %Proposal{
               title: "Voted Proposal Title",
               url: "https://kaize.io/proposal/voted_id-hash",
               status: :voted,
               up: 4,
               down: 1
             } = proposal
    end

    test "returns unvoted proposal from node" do
      node = H.doc("proposal/proposal_unvoted.html")
      {:ok, proposal} = NewProposal.call(node)

      assert %Proposal{
               title: "Unvoted Proposal Title",
               url: "https://kaize.io/proposal/unvoted_id-hash",
               status: :unvoted,
               up: 3,
               down: 4
             } = proposal
    end

    test "returns error when votes container is invalid" do
      node = H.doc("proposal/proposal_invalid_votes.html")

      assert {:error, :bad_vote_container} = NewProposal.call(node)
    end

    test "returns error when vote value is invalid" do
      node = H.doc("proposal/proposal_invalid_vote.html")

      assert {:error, :invalid_integer} = NewProposal.call(node)
    end

    test "returns error when url is invalid" do
      node = H.doc("proposal/proposal_invalid_url.html")

      assert {:error, :url_not_found} = NewProposal.call(node)
    end
  end
end
