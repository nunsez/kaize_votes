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
end
