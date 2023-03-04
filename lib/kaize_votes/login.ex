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

  @spec login() :: :ok | :error
  def login do
    login(Env.http_client())
  end

  @spec login(module()) :: :ok | :error
  def login(http_client) do
    Logger.info("Logging in")

    login_data = login_data(http_client)

    location =
      Constants.login_url()
      |> http_client.post(login_data)
      |> Http.location()

    case location do
      {:ok, _url} -> :ok
      _ -> :error
    end
  end

  @spec login_data(module()) :: map()
  defp login_data(http_client) do
    %{
      _token: auth_token(http_client),
      email: Env.email(),
      password: Env.password(),
      remember: Constants.remember_login()
    }
  end

  @spec auth_token(module()) :: String.t()
  def auth_token(http_client) do
    response = http_client.get(Constants.login_url())
    document = Html.parse(response.body)
    token_node = Html.find(document, "form.auth-form > input[name=\"_token\"]")

    Html.attribute(token_node, "value") || ""
  end
end
