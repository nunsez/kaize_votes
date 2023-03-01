defmodule KaizeVotes.Vote do
  @moduledoc false

  require Logger

  alias KaizeVotes.Constants
  alias KaizeVotes.Document
  alias KaizeVotes.Env
  alias KaizeVotes.Html

  @spec down(Html.document()) :: Html.document()
  def down(document) do
    down(document, Env.http_client())
  end

  @spec down(Html.document(), module()) :: Html.document()
  def down(document, http_client) do
    vote(document, Constants.vote_down(), http_client)
  end

  @spec up(Html.document()) :: Html.document()
  def up(document) do
    up(document, Env.http_client())
  end

  @spec up(Html.document(), module()) :: Html.document()
  def up(document, http_client) do
    vote(document, Constants.vote_up(), http_client)
  end

  @spec vote(Html.document(), String.t(), module()) :: Html.document()
  defp vote(document, value, http_client) do
    form = Html.find(document, "form.proposal-vote-form")
    url = Html.attribute(form, "action")

    Logger.info("Voting #{value}")
    http_client.post(url, Document.form_data(form, value))

    selector = ~s{form.proposal-vote-form input[name="vote"]}
    Html.attr(document, selector, "value", fn(_) -> value end)
  end
end
