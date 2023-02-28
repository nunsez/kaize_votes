defmodule KaizeVotes.CookieStore.FileAdapter do
  @moduledoc false

  @spec save_cookie(State.cookie(), Path.t()) :: :ok
  def save_cookie(cookie, path) do
    File.write!(path, cookie)
  end

  @spec read_cookie(Path.t()) :: State.cookie()
  def read_cookie(path) do
    path
    |> File.read!()
    |> String.trim()
  end

  @spec build_cookie_path(Path.t()) :: Path.t()
  def build_cookie_path(custom) do
    __MODULE__
    |> Application.get_application()
    |> Application.app_dir(["cookie_store", safe_custom(custom)])
  end

  @spec safe_custom(String.t() | nil) :: String.t()
  defp safe_custom("") do
    String.trim_leading(default_cookie_path(), "/")
  end

  defp safe_custom(nil) do
    String.trim_leading(default_cookie_path(), "/")
  end

  defp safe_custom(custom) when is_binary(custom) do
    String.trim_leading(custom, "/")
  end

  @spec ensure_store_exists(Path.t()) :: :ok
  def ensure_store_exists(filepath) do
    ensure_dir_exists(filepath)

    unless File.exists?(filepath) do
      File.touch!(filepath)
    end

    :ok
  end

  @spec ensure_dir_exists(Path.t()) :: :ok
  defp ensure_dir_exists(filepath) do
    dir = Path.dirname(filepath)

    unless File.exists?(dir) do
      File.mkdir_p!(dir)
    end

    :ok
  end

  @spec default_cookie_path() :: Path.t()
  def default_cookie_path do
    "cookie.txt"
  end
end
