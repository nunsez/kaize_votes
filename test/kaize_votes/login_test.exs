defmodule KaizeVotes.LoginTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest KaizeVotes.Login

  alias KaizeVotes.Login
  alias KaizeVotes.TestHelper, as: H

  describe "logged_in?/1" do
    test "when logged in" do
      doc = H.doc("login/logged_in.html")

      assert Login.logged_in?(doc)
    end

    test "when logged out" do
      doc = H.doc("login/logged_out.html")

      refute Login.logged_in?(doc)
    end
  end

  describe "logged_out?/1" do
    test "when logged in" do
      doc = H.doc("login/logged_in.html")

      refute Login.logged_out?(doc)
    end

    test "when logged out" do
      doc = H.doc("login/logged_out.html")

      assert Login.logged_out?(doc)
    end
  end

  describe "auth_token/1" do
    defmodule HttpAuthTokenMock do
      @moduledoc false

      def get(_) do
        %{
          status: 200,
          headers: [],
          body: H.fixture("login/login.html")
        }
      end
    end

    @tag :capture_log
    test "valid token" do
      token = Login.auth_token(HttpAuthTokenMock)

      assert token == "awesome_csrf_token"
    end
  end
end
