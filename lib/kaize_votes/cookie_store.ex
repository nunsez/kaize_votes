defmodule KaizeVotes.CookieStore do
  @moduledoc false

  use GenServer

  alias KaizeVotes.CookieStore.FileAdapter
  alias KaizeVotes.CookieStore.State

  # Client

  @spec start_link(keyword()) :: GenServer.on_start()
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

  # Server (callbacks)

  @impl GenServer
  @spec init(keyword()) :: {:ok, State.t()}
  def init(init_arg) do
    adapter = adapter()

    path = adapter.build_cookie_path(init_arg[:path])
    adapter.ensure_store_exists(path)

    state = State.new(path, adapter.read_cookie(path))

    {:ok, state}
  end

  @impl GenServer
  def handle_call(:get, _from, state) do
    %{cookie: cookie} = state

    {:reply, cookie, state}
  end

  @impl GenServer
  def handle_cast({:set, new_cookie}, state) do
    new_state = %{state | cookie: new_cookie}
    adapter().save_cookie(new_state.cookie, new_state.path)

    {:noreply, new_state}
  end

  def adapter do
    FileAdapter
  end
end
