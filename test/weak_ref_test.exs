defmodule WeakRefTest do
  use ExUnit.Case

  test "basic reference test" do
    tester = self()

    pid =
      spawn(fn ->
        {_ref, id} = WeakRef.new(tester)
        send(tester, {:id, id})

        receive do
          :stop -> :ok
        end
      end)

    # Stopping the pid should cleanup it's vars
    # and thus trigger the :DOWN message
    assert_receive {:id, id}
    send(pid, :stop)
    assert_receive {:DOWN, ^id, :weak_ref}
  end
end
