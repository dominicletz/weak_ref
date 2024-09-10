# WeakRef

WeakRef allows creating of weak references that when garbage collected will fire a "DOWN" message to a given process.

## Usage

This is an iex shell example, so we need to take care let the ref be garbage collected and not referenced by the history of the shell (reason for the `elem` call).

```elixir
pid = spawn(fn -> 
  receive do 
    {:DOWN, id, :weak_ref} ->
      IO.puts("The weak_ref with id=#{id} was garbage collected!")
  end
end)

elem(WeakRef.new(pid), 1)
```

## Installation

Add `:weak_ref` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:weak_ref, "~> 1.0.0"}
  ]
end
```
