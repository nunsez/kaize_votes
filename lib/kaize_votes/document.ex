defmodule KaizeVotes.Document do
  @moduledoc false

  require Logger

  alias KaizeVotes.Constants
  alias KaizeVotes.Env
  alias KaizeVotes.Html

  @spec enough_down_votes?(Html.document()) :: boolean()
  def enough_down_votes?(document) do
    count =
      document
      |> Html.find(".proposal-user-vote .choice.down")
      |> Enum.count()

    count >= Constants.vote_down_threshold()
  end

  @spec enough_up_votes?(Html.document()) :: boolean()
  def enough_up_votes?(document) do
    count =
      document
      |> Html.find(".proposal-user-vote .choice.up")
      |> Enum.count()

    count >= Constants.vote_up_threshold()
  end

  @spec votable?(Html.document()) :: boolean()
  def votable?(document) do
    selector = ~s{form.proposal-vote-form input[name="vote"]}
    input_value = Html.attribute(document, selector, "value")

    input_value == ""
  end

  @spec fetch_document(String.t()) :: Html.document()
  def fetch_document(url) do
    fetch_document(url, Env.http_client())
  end

  @spec fetch_document(String.t(), module()) :: Html.document()
  def fetch_document(url, http_client) do
    Logger.info("Fetch #{url}")
    response = http_client.get(url)

    Html.parse(response.body)
  end

  @spec form_data(Html.html_tree(), String.t()) :: map()
  def form_data(form, value) do
    %{
      _token: csrf_token(form),
      comment: "",
      vote: value,
      vote_id: ""
    }
  end

  @spec csrf_token(Html.html_tree()) :: String.t()
  defp csrf_token(form) do
    Html.attribute(form, ~s{input[name="_token"]}, "value")
  end
end
