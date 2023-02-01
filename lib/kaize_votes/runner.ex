defmodule KaizeVotes.Runner do
  @moduledoc false

  alias KaizeVotes.Http
  alias KaizeVotes.Html

  @spec call :: any()
  def call do
    # login()
    # home_page()
    GenServer.cast(KaizeVotes.Worker, :start)
  end

  def login do
    response = Http.get("https://kaize.io/login")
    document = Html.parse(response.body)
    token_element = Html.find(document, "form.auth-form > input[name=\"_token\"]")
    token = Html.attribute(token_element, "value")

    login_data = %{
      _token: token,
      email: Application.get_env(:kaize_votes, :email),
      password: Application.get_env(:kaize_votes, :password),
      remember: "on"
    }

    Http.post("https://kaize.io/login", login_data)
  end

  def home_page do
    response = Http.get("https://kaize.io/")
    document = Html.parse(response.body)
    Html.logged_in?(document)

    # File.write!("kaize.html", response.body)
  end
end
