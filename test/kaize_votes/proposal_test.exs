defmodule KaizeVotes.ProposalTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest KaizeVotes.Proposal

  alias KaizeVotes.Proposal
  alias KaizeVotes.TestHelper, as: H

  describe "list/1" do
    test "returns list of valid proposals from document" do
      doc = H.doc("proposal/proposal_index.html")
      result = Proposal.list(doc)

      assert Enum.count(result) == 7
    end
  end
end
