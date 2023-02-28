defmodule KaizeVotes.Http.Mock do
  @moduledoc false

  alias KaizeVotes.Http

  @spec get(String.t()) :: Http.response()
  def get(url) do
    %{
      status: 200,
      headers: [],
      body: url
    }
  end

  @spec post(String.t(), map()) :: Http.response()
  def post(url, _data) do
    %{
      status: 201,
      headers: [],
      body: url
    }
  end
end
