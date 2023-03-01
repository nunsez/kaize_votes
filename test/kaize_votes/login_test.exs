defmodule KaizeVotes.LoginTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest KaizeVotes.Login

  alias KaizeVotes.Env
  alias KaizeVotes.Html
  alias KaizeVotes.Login

  @spec doc(Path.t()) :: Html.document()
  def doc(file) do
    file
    |> html()
    |> Html.parse()
  end

  @spec html(Path.t()) :: String.t()
  def html(file) do
    file
    |> Path.expand(__DIR__)
    |> File.read!()
  end

  describe "logged_in?/1" do
    test "when logged in" do
      doc = doc("../fixtures/logged_in.html")

      assert Login.logged_in?(doc)
    end

    test "when logged out" do
      doc = doc("../fixtures/logged_out.html")

      refute Login.logged_in?(doc)
    end
  end

  describe "logged_out?/1" do
    test "when logged in" do
      doc = doc("../fixtures/logged_in.html")

      refute Login.logged_out?(doc)
    end

    test "when logged out" do
      doc = doc("../fixtures/logged_out.html")

      assert Login.logged_out?(doc)
    end
  end

  describe "login/1" do
    defmodule HttpLoginMock do
      @moduledoc false

      def get(_) do
        %{
          status: 200,
          headers: [],
          body: KaizeVotes.LoginTest.html("../fixtures/login.html")
        }
      end

      def post(url, data), do: {url, data}
    end

    @tag :capture_log
    test "works" do
      {_, login_data} = Login.login(HttpLoginMock)

      assert login_data._token == "2nLtzQrKYGmovAi7P1X5tMEKQhxEe5AvQGkQ98vE"
      assert login_data.email == Env.email()
      assert login_data.password == Env.password()
    end
  end
end
