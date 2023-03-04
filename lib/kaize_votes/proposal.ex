defmodule KaizeVotes.Proposal do
  @moduledoc false

  alias KaizeVotes.Html
  alias KaizeVotes.Proposal.NewProposal

  @derive {Inspect, []}

  defstruct [
    title: "",
    url: "",
    status: :closed,
    up: 0,
    down: 0
  ]

  @type status() :: :voted | :unvoted | :closed

  @type t() :: %__MODULE__{
    title: String.t(),
    url: String.t(),
    status: status(),
    up: non_neg_integer(),
    down: non_neg_integer()
  }

  @spec new(Html.html_node()) :: {:ok, t()} | {:error, atom()}
  defdelegate new(node), to: NewProposal, as: :call

  @spec list(Html.document()) :: [t()]
  def list(document) do
    document
    |> Html.find(".proposals-list .proposals-element")
    |> Stream.map(&new(&1))
    |> Stream.filter(&valid_proposal?(&1))
    |> Stream.map(fn({:ok, proposal}) -> proposal end)
    |> Enum.to_list()
  end

  @spec valid_proposal?({:ok, t()} | {:error, atom()}) :: boolean()
  defp valid_proposal?({:ok, _}), do: true
  defp valid_proposal?(_), do: false
end
