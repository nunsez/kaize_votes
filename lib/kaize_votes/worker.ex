defmodule KaizeVotes.Worker do
  @moduledoc false

  use GenServer

  require Logger

  alias KaizeVotes.Http
  alias KaizeVotes.Html

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl GenServer
  def init(_init_arg) do
    result =
      first_proporsal()
      |> ensure_logged_in()

    result
  end

  @impl GenServer
  def handle_cast(:start, document) do
    Process.send_after(self(), :started, 1_000)
    process(document)
  end

  def ensure_logged_in(document, try_count \\ 1)
  def ensure_logged_in(_, 3), do: {:error, "Can not login"}

  def ensure_logged_in(document, try_count) do
    if Html.logged_in?(document) do
      Logger.info("Already authenticated")
      {:ok, document}
    else
      Logger.info("Unauthenticated. Try to login, count: #{try_count}")
      Process.sleep(3000)
      KaizeVotes.Runner.login()
      doc = first_proporsal()
      ensure_logged_in(doc, try_count + 1)
    end
  end

  defp first_proporsal do
    Logger.info("first_proporsal")
    response = Http.get("https://kaize.io/proposal/1")
    Html.parse(response.body)
  end

  def process(document) do
    vote_input = Html.find(document, ~s|form.proposal-vote-form input[name="vote"][value=""]|)

    new_doc =
      if vote_input != [] do
        agree(document)
      else
        next_proporsal(document)
      end

    process(new_doc)
  end

  def next_proporsal(document) do
    Logger.info("next_proporsal")
    next_btn = Html.find(document, "a.next-proposal")

    if next_btn != [] do
      url = Html.attribute(next_btn, "href")
      response = Http.get(url) # get next proporsal
      Html.parse(response.body)
    else
      Process.sleep(5 * 60 * 1000) # wait new proporsals
      first_proporsal()
    end
  end

  def agree(document) do
    Logger.info("agree")
    form = Html.find(document, "form.proposal-vote-form")
    url = Html.attribute(form, "action")
    token_element = Html.find(document, ~s|form.proposal-vote-form input[name="_token"]|)
    token = Html.attribute(token_element, "value")
    data = %{
      _token: token,
      comment: "",
      vote: "up",
      vote_id: ""
    }

    Http.post(url, data) # vote up
    Process.sleep(5 * 1000)

    next_proporsal(document)
  end
end
