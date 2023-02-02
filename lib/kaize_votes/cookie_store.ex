defmodule KaizeVotes.CookieStore do
  use GenServer

  @default_path "cookie.txt"
  @default_cookie ""

  @type cookie :: String.t()

  @type state :: %{
    path: Path.t(),
    cookie: cookie()
  }

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
  @spec init(keyword()) :: {:ok, state()}
  def init(init_arg) do
    path = init_arg[:path] || @default_path
    ensure_store_exists(path)

    state = %{ path: path, cookie: read_cookie(path) }

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
    case File.exists?(filepath) do
      true -> :ok
      _ -> File.write!(filepath, @default_cookie)
    end
  end

  @spec save_cookie(cookie(), Path.t()) :: :ok
  defp save_cookie(cookie, path) do
    File.write!(path, cookie)
  end

  @spec read_cookie(Path.t()) :: cookie()
  defp read_cookie(path) do
    path
    |> File.read!()
    |> String.trim()
  end
end
