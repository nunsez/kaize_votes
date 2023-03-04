defmodule KaizeVotes.Worker2 do
  @moduledoc false

  use GenServer

  require Logger

  alias KaizeVotes.Constants
  alias KaizeVotes.Document
  alias KaizeVotes.Login
  alias KaizeVotes.Proposal
  alias KaizeVotes.Timeout
  alias KaizeVotes.Votable
  alias KaizeVotes.Vote

  @type state() :: %{
    proposals: [Proposal.t()]
  }

  # Client

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  # Server (callbacks)

  @impl GenServer
  @spec init(keyword()) :: {:ok, state()} | {:stop, String.t()}
  def init(_init_arg) do
    Process.send_after(self(), :enqueue, Timeout.before_next())

    {:ok, %{proposals: []}}
  end

  @impl GenServer
  def handle_info(:enqueue, state) do
    index = Document.fetch_document(Constants.proposal_index_url())

    if Login.logged_in?(index) do
      proposals =
        index
        |> Proposal.list()
        |> Enum.filter(&votable?/1)

      new_state = %{proposals: proposals}

      Process.send_after(self(), :iter, Timeout.before_next())

      {:noreply, new_state}
    else
      Process.send_after(self(), :login, Timeout.before_login())

      {:noreply, state}
    end
  end

  def handle_info(:login, state) do
    document = Document.fetch_document(Constants.proposal_index_url())

    if Login.logged_in?(document) do
      Process.send_after(self(), :enqueue, Timeout.before_next())

      {:noreply, state}
    else
      location = Login.login()

      case location do
        {:ok, _} ->
          Process.send_after(self(), :enqueue, Timeout.before_next())

          {:noreply, state}
        error ->
          Logger.error("Login failed, stop")

          {:stop, error}
      end
    end
  end

  def handle_info(:iter, %{proposals: []} = state) do
    Logger.info("There are no other proposals, waiting for new ones")

    Process.send_after(self(), :enqueue, Timeout.wait_new_proposals())

    {:noreply, state, :hibernate}
  end

  def handle_info(:iter, %{proposals: [proposal | rest]} = state) do
    document = Document.fetch_document(proposal.url)

    cond do
      Login.logged_out?(document) ->
        Process.send_after(self(), :login, Timeout.before_login())

      Votable.can_vote_down?(document) ->
        Process.sleep(Timeout.before_vote())
        Vote.down(document)

        new_state = %{state | proposals: rest}

        Process.send_after(self(), :iter, Timeout.before_next())

        {:noreply, new_state}

      Votable.can_vote_up?(document) ->
        Process.sleep(Timeout.before_vote())
        Vote.up(document)

        new_state = %{state | proposals: rest}

        Process.send_after(self(), :iter, Timeout.before_next())

        {:noreply, new_state}

      true ->
        Logger.info("Unexpected, skip: #{inspect(proposal)}")

        new_state = %{state | proposals: rest}

        {:noreply, new_state}
    end
  end

  def handle_info(msg, state) do
    Logger.error("Unexpected info message: #{inspect(msg)}")

    {:noreply, state}
  end

  @spec votable?(Proposal.t()) :: boolean()
  defp votable?(proposal) do
    if proposal.status == :unvoted do
      proposal.down >= Constants.vote_down_threshold()
        or proposal.up >= Constants.vote_up_threshold()
    else
      false
    end
  end
end
