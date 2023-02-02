defmodule KaizeVotes.Html do
  @moduledoc false

  @type html_tree() :: Floki.html_tree()
  @type html_node() :: Floki.html_node()
  @type document() :: html_tree() | html_node()

  @spec logged_in?(document()) :: boolean()
  def logged_in?(document) do
    find(document, "header .right > .account") != []
  end

  @spec parse(String.t()) :: html_tree()
  def parse(html) do
    case Floki.parse_document(html) do
      {:ok, document} -> document
      _ -> []
    end
  end

  @spec attribute(document(), String.t()) :: String.t() | nil
  def attribute([node | _], name) do
    attribute(node, name)
  end

  def attribute({_, attributes, _}, name) when is_list(attributes) do
    attribute = Enum.find(attributes, fn({attr_name, _}) -> attr_name == name end)

    case attribute do
      nil -> nil
      {_, value} -> value
    end
  end

  @spec find(document(), String.t()) :: html_tree()
  def find(document, selector) do
    Floki.find(document, selector)
  end
end
