defmodule KaizeVotes.Worker do
  @moduledoc false

  use GenServer

  require Logger

  alias KaizeVotes.Document
  alias KaizeVotes.Html
  alias KaizeVotes.Login
  alias KaizeVotes.Timeout
  alias KaizeVotes.Votable
  alias KaizeVotes.Vote

  @start_work ~T[02:00:00]
  @end_work ~T[16:00:00]

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
      Votable.can_vote_down?(document) ->
        Process.send_after(self(), :vote_down, Timeout.before_vote)

      Votable.can_vote_up?(document) ->
        Process.send_after(self(), :vote_up, Timeout.before_vote)

      Votable.can_next?(document)  ->
        Process.send_after(self(), :next, Timeout.before_next)

      Votable.rest_time?(@start_work, @end_work) ->
        Logger.info("Time to rest. Waiting for a new work day")

        NaiveDateTime.utc_now()
        |> Timeout.wait_untill(@start_work)
        |> reset()

      Login.logged_out?(document) ->
        Process.send_after(self(), :login, Timeout.before_login)

      true ->
        Logger.info("There are no other proposals, waiting for new ones")

        Timeout.wait_new_proposals
        |> reset()
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

  def handle_info(:vote_down, document) do
    new_doc = Vote.down(document)

    iter()

    {:noreply, new_doc}
  end

  def handle_info(:vote_up, document) do
    new_doc = Vote.up(document)

    iter()

    {:noreply, new_doc}
  end

  @spec iter() :: :ok
  defp iter, do: iter(Timeout.iteration)

  @spec iter(timeout()) :: :ok
  defp iter(timeout) do
    Process.send_after(self(), :iter, timeout)

    :ok
  end

  @spec reset() :: :ok
  defp reset, do: reset(Timeout.iteration)

  @spec reset(timeout()) :: :ok
  defp reset(timeout) do
    Process.send_after(self(), :reset, timeout)

    :ok
  end
end
