defmodule KaizeVotes.JsonTest do
  use ExUnit.Case, async: true
  doctest KaizeVotes.Json

  alias Kernel.ErrorHandler
  alias KaizeVotes.Json

  describe "optimistic cases" do
    test "parses string" do
      assert Json.parse(~s|"test string"|) == "test string"
    end

    test "parses integer" do
      assert Json.parse("42") === 42
    end

    test "parses object" do
      assert Json.parse(~s|{"token":"secret"}|) == %{ "token" => "secret" }
    end

    test "generates string from atom" do
      assert Json.generate(:foo) == ~s|"foo"|
    end

    test "generates integer" do
      assert Json.generate(777) == "777"
    end

    test "generates object" do
      assert Json.generate(%{ token: "secret" }) == ~s|{"token":"secret"}|
    end
  end
end
