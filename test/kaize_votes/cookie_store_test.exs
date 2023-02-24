defmodule KaizeVotes.CookieStoreTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest KaizeVotes.CookieStore

  alias KaizeVotes.CookieStore

  describe "init/1" do
    @tag :tmp_dir
    test "starts successfully when custom path exists", %{tmp_dir: tmp_dir} do
      path = Path.join(tmp_dir, "test_store")
      {:ok, _} = CookieStore.init(path: path)

      assert File.exists?(path)
    end

    @tag :tmp_dir
    test "starts successfully when custom path not exists", %{tmp_dir: tmp_dir} do
      dir = Path.join(tmp_dir, "nonexistent")

      refute File.exists?(dir)

      path = Path.join(dir, "test_store")
      {:ok, _} = CookieStore.init(path: path)

      assert File.exists?(path)
    end
  end
end
