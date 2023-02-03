defmodule KaizeVotes do
  @moduledoc """
  Documentation for `KaizeVotes`.
  """

  require Logger

  alias KaizeVotes.Html
  alias KaizeVotes.Http

  @spec login() :: Http.response()
  def login do
    Logger.info("Logging in")
    Http.post("https://kaize.io/login", login_data())
  end

  @spec login_data() :: map()
  defp login_data do
    %{
      _token: auth_token(),
      email: Application.get_env(:kaize_votes, :email),
      password: Application.get_env(:kaize_votes, :password),
      remember: "on"
    }
  end

  @spec auth_token() :: String.t()
  defp auth_token do
    response = Http.get("https://kaize.io/login")
    document = Html.parse(response.body)
    token_node = Html.find(document, "form.auth-form > input[name=\"_token\"]")

    Html.attribute(token_node, "value") || ""
  end

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
