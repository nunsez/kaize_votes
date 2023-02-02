defmodule Counter do
  use GenServer

  require Logger

  def start_link(init_arg) do
    Logger.info("start_link")
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl GenServer
  def init(init_arg) do
    Logger.info("init")
    state = %{count: init_arg}

    work()

    {:ok, state}
  end

  @impl GenServer
  def handle_info(:inc, state) do
    Logger.info("handle_info #{inspect(state)}")

    {:noreply, inc(state)}
  end

  def inc(state) do
    Logger.info("inc #{inspect(state)}")
    new_count = state.count + 1

    work()

    Logger.info("after work")

    %{state | count: new_count}
  end

  def work do
    Logger.info("before send after")
    Process.send_after(self(), :inc, :timer.seconds(2))
  end
end

IO.puts("Supervisor.start_link")
Supervisor.start_link([{Counter, 42}], strategy: :one_for_one)
Process.sleep(:timer.seconds(10))
