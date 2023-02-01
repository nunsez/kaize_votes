defmodule KaizeVotes.Html do
  @moduledoc false

  def find_token_element(document) do
    find(document, "form.auth-form > input[name=\"_token\"]")
  end

  def get_value(el) do
    [{_, attributes, _} | _] = el

    attributes
    |> Enum.find(fn(a) -> elem(a, 0) == "value" end)
    |> elem(1)
  end

  def logged_in?(document) do
    find(document, "header .right > .account") != nil
  end

  def parse(html) do
    case Floki.parse_document(html) do
      {:ok, document} -> document
      _ -> []
    end
  end

  def attribute({_, attributes, _}, name) when is_list(attributes) do
    attribute = Enum.find(attributes, fn({attr_name, _}) -> attr_name == name end)

    case attribute do
      nil -> nil
      {_, value} -> value
    end
  end

  def find(node, selector) do
    case find_all(node, selector) do
      [] -> nil
      [el | _] -> el
    end
  end

  def find_all(node, selector) do
    Floki.find(node, selector)
  end
end
