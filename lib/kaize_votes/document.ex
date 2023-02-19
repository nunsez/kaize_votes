defmodule KaizeVotes.Document do
  @moduledoc false

  require Logger

  alias KaizeVotes.Html
  alias KaizeVotes.Http

  @spec has_next_url?(Html.document()) :: boolean()
  def has_next_url?(document) do
    url = next_url(document)

    is_binary(url) and String.trim(url) != ""
  end

  @spec next(Html.document()) :: Html.document()
  def next(document) do
    document
    |> next_url()
    |> fetch_document()
  end

  @spec next_url(Html.document()) :: String.t() | nil
  defp next_url(document) do
    Html.attribute(document, "a.next-proposal", "href")
  end

  @spec fetch_document(String.t()) :: Html.document()
  def fetch_document(url) do
    Logger.info("Getting a proposal: #{url}")
    response = Http.get(url)

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
