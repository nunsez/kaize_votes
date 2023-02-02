defmodule KaizeVotes.Http do
  alias KaizeVotes.CookieStore
  alias KaizeVotes.Json

  @type response() :: map()
  @type header() :: {String.t(), String.t()}
  @type headers() :: [header()]

  @spec get(String.t()) :: response()
  def get(url) do
    headers = [{"content-type", "text/html"}, {"cookie", CookieStore.get()}]
    request = Finch.build(:get, url, headers)

    {:ok, response} = Finch.request(request, MyFinch)

    update_cookie(response)
  end

  @spec post(String.t(), map()) :: response()
  def post(url, data) do
    body = Json.generate(data)
    headers = [{"content-type", "application/json"}, {"cookie", CookieStore.get()}]
    request = Finch.build(:post, url, headers, body)

    {:ok, response} = Finch.request(request, MyFinch)

    update_cookie(response)
  end

  @spec update_cookie(response()) :: response()
  defp update_cookie(%{headers: headers} = response) do
    headers
    |> extract_cookies()
    |> CookieStore.set()

    response
  end

  @spec extract_cookies(headers()) :: String.t()
  def extract_cookies(headers) when is_list(headers) do
    headers
      |> Stream.filter(&cookie_header?/1)
      |> Stream.map(&elem(&1, 1))
      |> Stream.map(&drop_cookie_opts/1)
      |> Enum.join("; ")
  end

  @spec cookie_header?(header()) :: boolean()
  defp cookie_header?({key, _}) do
    String.match?(key, ~r/\Aset-cookie\z/i)
  end

  @spec drop_cookie_opts(String.t()) :: String.t()
  defp drop_cookie_opts(cookie) do
    [value | _opts] = String.split(cookie, ";", parts: 2)
    value
  end
end
