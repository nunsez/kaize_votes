defmodule KaizeVotes.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl Application
  @spec start(any(), any()) :: {:error, any()} | {:ok, pid()}
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: KaizeVotes.Worker.start_link(arg)
      # {KaizeVotes.Worker, arg}
      {KaizeVotes.CookieStore, [path: "cookie.txt"]},
      {Finch, name: MyFinch},
      {KaizeVotes.Worker, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KaizeVotes.Supervisor]
    result = Supervisor.start_link(children, opts)

    KaizeVotes.start()
    result
  end
end
