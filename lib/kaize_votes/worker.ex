defmodule KaizeVotes.Worker do
  @moduledoc false

  use GenServer

  require Logger

  alias KaizeVotes.Http
  alias KaizeVotes.Html

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
    new_doc = fetch_document(@first_proposal)

    iter()

    {:ok, new_doc}
  end

  @impl GenServer
  def handle_info(:iter, document) do
    cond do
      Html.can_vote?(document) ->
        Process.send_after(self(), :vote, :timer.seconds(5))

      Html.can_next?(document) ->
        Process.send_after(self(), :next, :timer.seconds(2))

      Html.logged_out?(document) ->
        Process.send_after(self(), :login, :timer.seconds(3))

      true ->
        Logger.info("There are no other proposals, waiting for new ones")
        iter(:timer.minutes(5))
    end

    {:noreply, document}
  end

  def handle_info(:login, _document) do
    Logger.info("Logging in")
    KaizeVotes.login()

    :timer.sleep(1_000)
    new_doc = fetch_document(@first_proposal)

    iter()

    {:noreply, new_doc}
  end

  def handle_info(:next, document) do
    new_doc = next(document)

    iter()

    {:noreply, new_doc}
  end

  def handle_info(:vote, document) do
    new_doc = vote_up(document)

    iter()

    {:noreply, new_doc}
  end

  @spec iter(timeout()) :: :ok
  defp iter(timeout \\ 1_000) do
    Process.send_after(self(), :iter, timeout)

    :ok
  end

  @spec vote_up(Html.document()) :: Html.document()
  defp vote_up(document) do
    form = Html.find(document, "form.proposal-vote-form")
    url = Html.attribute(form, "action")

    Logger.info("Voting up")
    Http.post(url, Html.agree_data(form))

    selector = ~s{form.proposal-vote-form input[name="vote"]}
    Html.attr(document, selector, "value", fn(_) -> "1" end)
  end

  @spec next(Html.document()) :: Html.document()
  defp next(document) do
    document
    |> Html.attribute("a.next-proposal", "href")
    |> fetch_document()
  end

  @spec fetch_document(String.t()) :: Html.document()
  def fetch_document(url) do
    Logger.info("Getting a proposal: #{url}")
    response = Http.get(url)

    Html.parse(response.body)
  end
end
