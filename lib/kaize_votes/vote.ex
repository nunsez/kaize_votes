defmodule KaizeVotes.Vote do
  @moduledoc false

  require Logger

  alias KaizeVotes.Document
  alias KaizeVotes.Html
  alias KaizeVotes.Http

  @spec down(Html.document()) :: Html.document()
  def down(document) do
    vote(document, "down")
  end

  @spec up(Html.document()) :: Html.document()
  def up(document) do
    vote(document, "up")
  end

  @spec vote(Html.document(), String.t()) :: Html.document()
  defp vote(document, value) do
    form = Html.find(document, "form.proposal-vote-form")
    url = Html.attribute(form, "action")

    Logger.info("Voting #{value}")
    Http.post(url, Document.form_data(form, value))

    selector = ~s{form.proposal-vote-form input[name="vote"]}
    Html.attr(document, selector, "value", fn(_) -> value end)
  end
end
