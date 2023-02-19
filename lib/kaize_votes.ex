defmodule KaizeVotes do
  @moduledoc """
  Documentation for `KaizeVotes`.
  """

  require Logger

  alias KaizeVotes.Html
  alias KaizeVotes.Http

  @spec vote_up(Html.document()) :: Html.document()
  def vote_up(document) do
    form = Html.find(document, "form.proposal-vote-form")
    url = Html.attribute(form, "action")

    Logger.info("Voting up")
    Http.post(url, Html.agree_data(form))

    selector = ~s{form.proposal-vote-form input[name="vote"]}
    Html.attr(document, selector, "value", fn(_) -> "1" end)
  end

  @spec next(Html.document()) :: Html.document()
  def next(document) do
    document
    |> Html.attribute("a.next-proposal", "href")
    |> fetch_document()
  end

  @spec fetch_document(String.t()) :: Html.document()
  def fetch_document(url) do
    Logger.info("Getting a proposal: #{url}")
    response = Http.get(url)

    Html.parse(response.body)
  end
end
