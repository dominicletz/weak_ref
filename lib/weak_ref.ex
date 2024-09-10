defmodule WeakRef do
  @on_load :load_nifs

  @doc false
  def load_nifs do
    :ok =
      case :code.priv_dir(:weak_ref) do
        {:error, :bad_name} ->
          if File.dir?(Path.join("..", "priv")) do
            Path.join("..", "priv")
          else
            "priv"
          end

        path ->
          path
      end
      |> Path.join("weak_ref_nif")
      |> String.to_charlist()
      |> :erlang.load_nif(0)
  end

  @doc """
  Creates a new weak reference which will send :DOWN to `self()` when garbage collected

  Returns a tuple of `{ref, id}` where `ref` is the reference and `id` is the id of the reference.
  """
  def new() do
    new(self())
  end

  @doc """
  Creates a new weak reference which will send :DOWN to the given owner pid when garbage collected

  Returns a tuple of `{ref, id}` where `ref` is the reference and `id` is the id of the reference.
  """
  def new(_owner_pid) do
    raise "NIF library not loaded"
  end
end
