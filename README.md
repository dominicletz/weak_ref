# WeakRef

WeakRef allows creating of weak references that when garbage collected will fire a "DOWN" message to a given process.

## Usage

`{strong, weak} = WeakRef.new(owner_pid \\ self())` creates a tangled pair of a strong and a weak reference. The strong reference is a `#Resource` and once all of it's copies are garbage collect there is a message `{:DOWN, weak, :weak_ref}` sent to the `owner_pid` process to let it know that the strong references have all gone away.

This allows implementing logic to clean up external resources when there are no internal references to those available. 

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
