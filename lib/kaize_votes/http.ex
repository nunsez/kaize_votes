defmodule KaizeVotes.Http do
  alias KaizeVotes.CookieStore
  alias KaizeVotes.Json

  def get(url) do
    {:ok, response} =
      Finch.build(:get, url, [{"content-type", "text/html"}, {"cookie", CookieStore.get()}])
      |> Finch.request(MyFinch)

    update_cookie(response)
  end

  def post(url, data) do
    json = Json.generate(data)
    headers = [{"content-type", "application/json"}, {"cookie", CookieStore.get()}]

    {:ok, response} =
      Finch.build(:post, url, headers, json)
      |> Finch.request(MyFinch)

    update_cookie(response)
  end

  def update_cookie(response) do
    response.headers
    |> extract_cookies()
    |> CookieStore.set()

    response
  end

  def extract_cookies(headers) when is_list(headers) do
    headers
      |> Enum.filter(fn({key, _}) -> String.match?(key, ~r/\Aset-cookie\z/i) end)
      |> Enum.map(fn({_, cookie}) ->
        [value, _] = String.split(cookie, ";", parts: 2)
        value
      end)
      |> Enum.join("; ")
  end
end
