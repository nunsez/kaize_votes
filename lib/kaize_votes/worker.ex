defmodule KaizeVotes.Worker do
  @moduledoc false

  use GenServer

  require Logger

  alias KaizeVotes.Document
  alias KaizeVotes.Html
  alias KaizeVotes.Login

  @first_proposal "https://kaize.io/proposal/1"

  @type state() :: Html.document()

  # Client

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  # Server (callbacks)

  @impl GenServer
  @spec init(keyword()) :: {:ok, state()} | {:stop, String.t()}
  def init(_init_arg) do
    reset()

    {:ok, []}
  end

  @impl GenServer
  def handle_info(:reset, _document) do
    new_doc = Document.fetch_document(@first_proposal)

    iter()

    {:noreply, new_doc}
  end

  def handle_info(:iter, document) do
    cond do
      Html.can_vote?(document) ->
        Process.send_after(self(), :vote, :timer.seconds(5))

      Document.can_next?(document) ->
        Process.send_after(self(), :next, :timer.seconds(2))

      Login.logged_out?(document) ->
        Process.send_after(self(), :login, :timer.seconds(3))

      true ->
        Logger.info("There are no other proposals, waiting for new ones")
        reset(:timer.minutes(5))
    end

    {:noreply, document}
  end

  def handle_info(:login, document) do
    Login.login()

    reset()

    {:noreply, document}
  end

  def handle_info(:next, document) do
    new_doc = Document.next(document)

    iter()

    {:noreply, new_doc}
  end

  def handle_info(:vote, document) do
    new_doc = KaizeVotes.vote_up(document)

    iter()

    {:noreply, new_doc}
  end

  @spec iter(timeout()) :: :ok
  defp iter(timeout \\ 1_000) do
    Process.send_after(self(), :iter, timeout)

    :ok
  end

  @spec reset(timeout()) :: :ok
  defp reset(timeout \\ 1_000) do
    Process.send_after(self(), :reset, timeout)

    :ok
  end
end
