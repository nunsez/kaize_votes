defmodule KaizeVotes.CookieStore do
  @moduledoc false

  use GenServer

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
    path = build_cookie_path(init_arg[:path] || default_cookie_path())
    ensure_store_exists(path)

    state = State.new(path, read_cookie(path))

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
    save_cookie(new_state.cookie, new_state.path)

    {:noreply, new_state}
  end

  @spec ensure_store_exists(Path.t()) :: :ok
  defp ensure_store_exists(filepath) do
    ensure_dir_exists(filepath)

    unless File.exists?(filepath) do
      File.touch!(filepath)
    end

    :ok
  end

  @spec ensure_dir_exists(Path.t()) :: :ok
  def ensure_dir_exists(filepath) do
    dir = Path.dirname(filepath)

    unless File.exists?(dir) do
      File.mkdir_p!(dir)
    end

    :ok
  end

  @spec save_cookie(State.cookie(), Path.t()) :: :ok
  defp save_cookie(cookie, path) do
    File.write!(path, cookie)
  end

  @spec read_cookie(Path.t()) :: State.cookie()
  defp read_cookie(path) do
    path
    |> File.read!()
    |> String.trim()
  end

  @spec build_cookie_path(Path.t()) :: Path.t()
  def build_cookie_path(custom) do
    safe_custom = String.trim_leading(custom, "/")

    __MODULE__
    |> Application.get_application()
    |> Application.app_dir(["cookie_store", safe_custom])
  end

  @spec default_cookie_path() :: Path.t()
  def default_cookie_path do
    "cookie.txt"
  end
end
