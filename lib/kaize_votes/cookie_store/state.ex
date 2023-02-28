defmodule KaizeVotes.CookieStore.State do
  @moduledoc false

  @enforce_keys [:path]

  defstruct [
    path: nil,
    cookie: ""
  ]

  @type cookie() :: String.t()

  @type t() :: %__MODULE__{}

  @spec new(Path.t(), cookie()) :: t()
  def new(path, cookie) do
    %__MODULE__{path: path, cookie: cookie}
  end

  @spec new(Path.t()) :: t()
  def new(path) do
    %__MODULE__{path: path}
  end
end
