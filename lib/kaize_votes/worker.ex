defmodule KaizeVotes.Worker do
  use GenServer

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

  def ensure_logged_in(document, try_count \\ 1)
  def ensure_logged_in(_, 3), do: {:error, "Can not login"}

  def ensure_logged_in(document, try_count) do
    if Html.logged_in?(document) do
      IO.puts("Already authenticated")
      {:ok, document}
    else
      IO.puts("Unauthenticated. Try to login, count: #{try_count}")
      Process.sleep(3000)
      KaizeVotes.Runner.login()
      doc = first_proporsal()
      ensure_logged_in(doc, try_count + 1)
    end
  end

  defp first_proporsal do
    response = Http.get("https://kaize.io/proposal/1")
    Html.parse(response.body)
  end

  def already_voted?(form) do
    Html.find(form, ~s|input[name="vote"][value="up"]|) != nil
  end

  def process(document) do
    form = Html.find(form, "form.proposal-vote-form")
    new_doc = nil

    if !form or already_voted?(form) do
      new_doc = next_proporsal(document)
    else
      new_doc = agree(document)
    end

    process(new_doc)
  end

  def next_proporsal(document) do
    next_btn = Html.find(document, "a.next-proposal")

    if next_btn do
      url = Html.attribute(next_btn, "href")
      Html.get(url) # get next proporsal
    else
      Process.sleep(5 * 60 * 1000) # wait new proporsals
      first_proporsal
    end
  end

  def agree(document) do
    form = Html.find(form, "form.proposal-vote-form")
    token_element = Html.find(form, ~s|input[name="_token"]|)
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
