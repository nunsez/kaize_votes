defmodule KaizeVotes.Document do
  @moduledoc false

  require Logger

  alias KaizeVotes.Html
  alias KaizeVotes.Http

  @spec can_next?(Html.document()) :: boolean()
  def can_next?(document) do
    url = Html.attribute(document, "a.next-proposal", "href")

    case url do
      s when is_binary(s) -> String.trim(s) != ""
      _ -> false
    end
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
