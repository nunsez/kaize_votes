defmodule KaizeVotes.CookieStore do
  use GenServer

  @filepath "cookie.txt"
  @default_cookie ""

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @spec get() :: String.t()
  def get do
    GenServer.call(__MODULE__, :get)
  end

  @spec set(String.t()) :: :ok
  def set(value) do
    GenServer.cast(__MODULE__, {:set, value})
  end

  @impl GenServer
  def init(_init_arg) do
    ensure_store_exists()

    value =
      @filepath
      |> File.read!()
      |> String.trim()

    {:ok, value}
  end

  @impl GenServer
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_cast({:set, new_value}, _state) do
    File.write!(@filepath, new_value)
    {:noreply, new_value}
  end

  defp ensure_store_exists do
    unless File.exists?(@filepath) do
      File.write!(@filepath, @default_cookie)
    end
  end
end
