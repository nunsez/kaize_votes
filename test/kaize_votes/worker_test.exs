defmodule KaizeVotes.WorkerTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest KaizeVotes.Worker

  alias KaizeVotes.Worker

  describe "init/1" do
    test "returns state with empty proposals" do
      result = Worker.init([])

      assert result == {:ok, %{proposals: []}}
    end
  end
end
