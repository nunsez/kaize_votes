defmodule KaizeVotes.CookieStoreTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest KaizeVotes.CookieStore

  alias KaizeVotes.CookieStore

  describe "init/1" do
    test "starts successfully with default custom path" do
      # ensure path not exists
      CookieStore.default_cookie_path()
      |> File.rm_rf!()

      assert {:ok, _} = CookieStore.init([])
    end

    test "starts successfully with custom path" do
      relative = "custom path exists"

      path = CookieStore.build_cookie_path(relative)

      # ensure path not exists
      File.rm_rf!(path)

      assert {:ok, _} = CookieStore.init(path: relative)
    end

    test "starts successfully when custom path with dir" do
      relative = "test_nested/cookie_path"

      path = CookieStore.build_cookie_path(relative)

      # ensure directory not exists
      path
      |> Path.dirname()
      |> File.rm_rf!()

      assert {:ok, _} = CookieStore.init(path: relative)
    end

    test "starts successfully with existing cookie" do
      relative = "with_cookie_value"
      value = "cookie value here"

      path = CookieStore.build_cookie_path(relative)
      File.write!(path, "cookie value here")

      assert {:ok, _} = CookieStore.init(path: relative)
      assert File.read!(path) == value
    end
  end

  describe "handle_call/3 :get" do
    test "get cookie" do
      state = %{cookie: "xxx"}

      {:reply, cookie, _} = CookieStore.handle_call(:get, self(), state)

      assert cookie === "xxx"
    end
  end
end
