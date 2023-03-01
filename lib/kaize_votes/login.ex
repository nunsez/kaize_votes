defmodule KaizeVotes.Login do
  @moduledoc false

  require Logger

  alias KaizeVotes.Constants
  alias KaizeVotes.Env
  alias KaizeVotes.Html
  alias KaizeVotes.Http

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
    login(Env.http_client())
  end

  @spec login(module()) :: Http.response()
  def login(http_client) do
    Logger.info("Logging in")
    http_client.post(Constants.login_url(), login_data())
  end

  @spec login_data() :: map()
  defp login_data do
    %{
      _token: auth_token(),
      email: Env.email(),
      password: Env.password(),
      remember: Constants.remember_login()
    }
  end

  @spec auth_token() :: String.t()
  defp auth_token do
    auth_token(Env.http_client())
  end

  @spec auth_token(module()) :: String.t()
  defp auth_token(http_client) do
    response = http_client.get(Constants.login_url())
    document = Html.parse(response.body)
    token_node = Html.find(document, "form.auth-form > input[name=\"_token\"]")

    Html.attribute(token_node, "value") || ""
  end
end
