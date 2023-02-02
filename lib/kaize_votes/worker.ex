defmodule KaizeVotes.Worker do
  @moduledoc false

  use GenServer

  require Logger

  alias KaizeVotes.Http
  alias KaizeVotes.Html

  @first_proporsal "https://kaize.io/proposal/1"

  @type state() :: Html.document()

  # Client

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @spec start() :: :ok
  def start do
    GenServer.cast(__MODULE__, :start)
  end

  # Server (callbacks)

  @impl GenServer
  @spec init(keyword()) :: {:ok, state()} | {:stop, String.t()}
  def init(_init_arg) do
    result =
      fetch_document(@first_proporsal)
      |> ensure_logged_in()

    case result do
      {:ok, document} ->
        state = document
        {:ok, state}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl GenServer
  def handle_cast(:start, document) do
    Process.send_after(self(), :started, 1_000)
    process(document)
  end

  @spec ensure_logged_in(Html.document(), pos_integer()) ::
    {:ok, Html.document()} | {:error, String.t()}
  def ensure_logged_in(document, try_count \\ 1)
  def ensure_logged_in(_, 3), do: {:error, "Can not login"}

  def ensure_logged_in(document, try_count) do
    if Html.logged_in?(document) do
      Logger.info("Already authenticated")

      {:ok, document}
    else
      Logger.info("Unauthenticated. Try to login, count: #{try_count}")
      KaizeVotes.login()

      Process.sleep(:timer.seconds(3))
      new_doc = fetch_document(@first_proporsal)

      ensure_logged_in(new_doc, try_count + 1)
    end
  end

  @spec process(Html.document()) :: Html.document()
  def process(document) do
    form = Html.find(document, "form.proposal-vote-form")
    vote_input = Html.find(form, ~s|input[name="vote"][value=""]|)

    if vote_input != [] do
      agree(form)
      Process.sleep(:timer.seconds(5))
    end

    new_doc = next_proporsal(document)
    process(new_doc)
  end

  @spec next_proporsal(Html.document()) :: Html.document()
  def next_proporsal(document) do
    next_btn = Html.find(document, "a.next-proposal")

    if next_btn != [] do
      url = Html.attribute(next_btn, "href")

      fetch_document(url)
    else
      Logger.info("There are no remaining proporsals, wait")
      Process.sleep(:timer.minutes(5))

      fetch_document(@first_proporsal)
    end
  end

  @spec fetch_document(String.t()) :: Html.document()
  def fetch_document(url) do
    Logger.info("Getting proporsal: #{url}")
    response = Http.get(url)

    Html.parse(response.body)
  end

  @spec agree(Html.document()) :: :ok
  def agree(form) do
    url = Html.attribute(form, "action")

    Logger.info("Voting up")
    Http.post(url, agree_data(form))

    :ok
  end

  @spec agree_data(Html.document()) :: map()
  defp agree_data(form) do
    token = Html.attribute(form, ~s|input[name="_token"]|, "value")

    %{
      _token: token,
      comment: "",
      vote: "up",
      vote_id: ""
    }
  end
end
