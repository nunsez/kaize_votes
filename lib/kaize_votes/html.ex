defmodule KaizeVotes.Html do
  @moduledoc false

  @type html_tree() :: Floki.html_tree()
  @type html_node() :: Floki.html_node()
  @type document() :: html_tree() | html_node()

  @spec logged_in?(document()) :: boolean()
  def logged_in?(document) do
    find(document, "header .right > .account") != []
  end

  @spec logged_out?(document()) :: boolean()
  def logged_out?(document) do
    not logged_in?(document)
  end

  @spec can_vote?(document()) :: boolean()
  def can_vote?(document) do
    selector = ~s{form.proposal-vote-form input[name="vote"]}
    input_value = attribute(document, selector, "value")

    case input_value do
      "" -> true
      _ -> false
    end
  end

  @spec can_next?(document()) :: boolean()
  def can_next?(document) do
    url = attribute(document, "a.next-proposal", "href")

    case url do
      s when is_binary(s) -> String.trim(s) != ""
      _ -> false
    end
  end

  @spec agree_data(document()) :: map()
  def agree_data(form) do
    token = attribute(form, ~s|input[name="_token"]|, "value")

    %{
      _token: token,
      comment: "",
      vote: "up",
      vote_id: ""
    }
  end

  @spec parse(String.t()) :: html_tree()
  def parse(html) do
    case Floki.parse_document(html) do
      {:ok, document} -> document
      _ -> []
    end
  end

  @spec find(document(), String.t()) :: html_tree()
  def find(document, selector) do
    Floki.find(document, selector)
  end

  @spec attribute(document(), String.t()) :: String.t() | nil
  def attribute(document, name) do
    case Floki.attribute(document, name) do
      [value | _] -> value
      _ -> nil
    end
  end

  @spec attribute(document(), String.t(), String.t()) :: String.t() | nil
  def attribute(document, selector, name) do
    case Floki.attribute(document, selector, name) do
      [value | _] -> value
      _ -> nil
    end
  end

  @spec attr(document(), String.t(), String.t(), (String.t() -> String.t())) :: document()
  def attr(document, selector, attribute, func) do
    Floki.attr(document, selector, attribute, func)
  end
end
