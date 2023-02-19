defmodule KaizeVotes.Login do
  @moduledoc false

  require Logger

  alias KaizeVotes.Html
  alias KaizeVotes.Http

  @login_url "https://kaize.io/login"

  @spec logged_in?(Html.document()) :: boolean()
  def logged_in?(document) do
    Html.find(document, "header .right > .account") != []
  end

  @spec logged_out?(Html.document()) :: boolean()
  def logged_out?(document) do
    not logged_in?(document)
  end

  @spec login() :: Http.response()
  def login do
    Logger.info("Logging in")
    Http.post(@login_url, login_data())
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
    response = Http.get(@login_url)
    document = Html.parse(response.body)
    token_node = Html.find(document, "form.auth-form > input[name=\"_token\"]")

    Html.attribute(token_node, "value") || ""
  end
end
