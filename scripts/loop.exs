spawn(fn ->
  tester = self()

  for y <- 1..10000 do
    for _x <- 1..10000 do
      spawn(fn ->
        {_ref, id} = WeakRef.new(tester)
        send(tester, {:id, id})

        receive do
          :stop -> :ok
        end
      end)
      |> send(:stop)
    end


    for _x <- 1..10000 do
      receive do
        {:id, _id} -> :ok
      end
    end
    :erlang.garbage_collect()
    IO.puts("Run #{y}")
  end
end)

Process.sleep(:infinity)
