defmodule KaizeVotes.Proposal.NewProposal do
  @moduledoc false

  alias KaizeVotes.Html
  alias KaizeVotes.Proposal

  @spec call(Html.html_node()) :: {:ok, Proposal.t()} | {:error, atom()}
  def call(node) do
    with {:ok, up_node, down_node} <- vote_containers(node),
          {:ok, up} <- extract_number(up_node),
          {:ok, down} <- extract_number(down_node),
          {:ok, url} <- url(node) do

      proposal = %Proposal{
        title: title(node),
        url: url,
        status: status(node),
        up: up,
        down: down
      }

      {:ok, proposal}
    else
      error -> error
    end
  end

  @spec title(Html.html_node()) :: Strint.t()
  defp title(node) do
    title_node = Html.find(node, ".datas .title")

    case title_node do
      [{_, _, [title]} | _] -> title
      _ -> "Untitled"
    end
  end

  @spec url(Html.html_node()) :: Strint.t() | nil
  defp url(node) do
    result = Html.attribute(node, ".datas .proposal-status ~ a", "href")

    cond do
      is_nil(result) -> {:error, :url_not_found}
      (url = String.trim(result)) != "" -> {:ok, url}
      true -> {:error, :url_not_found}
    end
  end

  @spec extract_number(Html.html_node()) ::
    {:ok, integer()} | {:error, :invalid_number} | {:error, :vote_not_found}
  defp extract_number(vote_node) do
    result = Html.find(vote_node, ".vote-number")

    case result do
      [{_, _, [value]} | _] -> to_integer(value)
      _ -> {:error, :vote_not_found}
    end
  end

  @spec to_integer(String.t()) :: {:ok, integer()} | {:error, :invalid_integer}
  defp to_integer(value) do
    {:ok, String.to_integer(value, 10)}
  rescue
    _ -> {:error, :invalid_integer}
  end

  @spec vote_containers(Html.html_node()) ::
    {:ok, Html.html_node(), Html.html_node()} | {:error, :bad_vote_container}
  defp vote_containers(node) do
    result = Html.find(node, ".proposals-votes .vote-container")

    case result do
      [_, up_node, down_node] -> {:ok, up_node, down_node}
      _ -> {:error, :bad_vote_container}
    end
  end

  @spec status(Html.html_node()) :: Proposal.status()
  defp status(node) do
    cond do
      Html.find(node, ".datas .proposal-status.open") == [] ->
        :closed

      Html.find(node, ".datas .your-vote") == [] ->
        :unvoted

      true ->
        :voted
    end
  end
end
