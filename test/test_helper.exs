ExUnit.start()

defmodule KaizeVotes.TestHelper do
  @moduledoc false

  alias KaizeVotes.Html

  @spec fixture(Path.t()) :: String.t()
  defmacro fixture(path) do
    quote do
      unquote(path)
      |> Path.expand(__DIR__)
      |> File.read!()
    end
  end

  @spec doc(Path.t()) :: Html.document()
  defmacro doc(file) do
    quote do
      unquote(file)
      |> fixture()
      |> Html.parse()
    end
  end
end
