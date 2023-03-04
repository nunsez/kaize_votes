defmodule KaizeVotes.HttpTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest KaizeVotes.Http

  alias KaizeVotes.Http

  describe "location/1" do
    test "when location present" do
      response = %{
        headers: [
          {"content-type", "text/html; charset=UTF-8"},
          {"location", "https://example.com"}
        ]
      }

      result = Http.location(response)

      assert result == {:ok, "https://example.com"}
    end

    test "when multiple locations" do
      response = %{
        headers: [
          {"content-type", "text/html; charset=UTF-8"},
          {"location", "https://example.com"},
          {"location", "https://example-two.com"}
        ]
      }

      result = Http.location(response)

      assert result == {:ok, "https://example-two.com"}
    end

    test "when no location" do
      response = %{
        headers: [
          {"content-type", "text/html; charset=UTF-8"}
        ]
      }

      result = Http.location(response)

      assert result == {:error, :no_location}
    end

    test "when empty headers" do
      response = %{
        headers: []
      }

      result = Http.location(response)

      assert result == {:error, :no_location}
    end
  end
end
