defmodule KaizeVotes.DocumentTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest KaizeVotes.Document

  alias KaizeVotes.Document
  alias KaizeVotes.TestHelper, as: H

  describe "has_next_url?/1" do
    test "document with next proposal" do
      doc = H.doc("document/proposal_with_next.html")

      assert Document.has_next_url?(doc)
    end

    test "document without next proposal" do
      doc = H.doc("document/proposal_without_next.html")

      refute Document.has_next_url?(doc)
    end
  end

  defmodule HttpNextMock do
    @moduledoc false

    def get("https://kaize.io/proposal/next_number") do
      %{
        status: 200,
        headers: [],
        body: "<html></html>"
      }
    end
  end

  describe "next/2" do
    @tag :capture_log
    test "next successfully" do
      doc = H.doc("document/form_data_down.html")
      result = Document.next(doc, HttpNextMock)

      assert result == [{"html", [], []}]
    end
  end

  describe "enough_down_votes?/1" do
    test "when 1 up" do
      doc = H.doc("document/proposal_1_up.html")

      refute Document.enough_down_votes?(doc)
    end

    test "when 4 down and 4 up" do
      doc = H.doc("document/proposal_4_down_4_up.html")

      assert Document.enough_down_votes?(doc)
    end

    test "when 4 down" do
      doc = H.doc("document/proposal_4_down.html")

      assert Document.enough_down_votes?(doc)
    end

    test "when 4 up" do
      doc = H.doc("document/proposal_4_up.html")

      refute Document.enough_down_votes?(doc)
    end
  end

  describe "enough_up_votes?/1" do
    test "when 1 up" do
      doc = H.doc("document/proposal_1_up.html")

      refute Document.enough_up_votes?(doc)
    end

    test "when 4 down and 4 up" do
      doc = H.doc("document/proposal_4_down_4_up.html")

      assert Document.enough_up_votes?(doc)
    end

    test "when 4 down" do
      doc = H.doc("document/proposal_4_down.html")

      refute Document.enough_up_votes?(doc)
    end

    test "when 4 up" do
      doc = H.doc("document/proposal_4_up.html")

      assert Document.enough_up_votes?(doc)
    end
  end

  describe "votable?/1" do
    test "when votable" do
      form = H.doc("document/form_votable.html")

      assert Document.votable?(form)
    end

    test "when not votable" do
      form = H.doc("document/form_data_down.html")

      refute Document.votable?(form)
    end
  end

  defmodule HttpFetchDocumentMock do
    @moduledoc false

    def get("url here") do
      %{
        status: 200,
        headers: [],
        body: "<html></html>"
      }
    end
  end

  describe "fetch_document/2" do
    @tag :capture_log
    test "fetches successfully" do
      result = Document.fetch_document("url here", HttpFetchDocumentMock)

      assert result == [{"html", [], []}]
    end
  end

  describe "form_data/2" do
    test "overrides existing vote value" do
      form = H.doc("document/form_data_down.html")

      form_data = Document.form_data(form, "up")

      assert form_data.vote == "up"
      assert form_data._token == "awesome_csrf_token"
      assert form_data.vote_id == ""
      assert form_data.comment == ""
    end
  end
end
