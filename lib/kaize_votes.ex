defmodule KaizeVotes do
  @moduledoc """
  Documentation for `KaizeVotes`.
  """

  alias KaizeVotes.Html
  alias KaizeVotes.Http

  @spec login() :: Http.response()
  def login do
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
end
