defmodule PgMqttBridge.ToPg do
  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: :to_pg)
  end

  def init(state) do
    connect_loop()
    {:ok, counter} = Agent.start(fn -> 0 end)
    Process.register(counter, :to_pg_counter)
    {:ok, state}
  end

  def connect_loop() do
    conn =
      Postgrex.start_link(
        pool: DBConnection.Poolboy,
        name: :ToPg_Poolboy,
        pool_size: 50,
        database: "enet_dev",
        username: "postgres",
        password: "postgres",
        hostname: "localhost"
      )

    case conn do
      {:ok, pid} ->
        IO.puts("Connected to DB.")

      # Process.register(pid, :pg_to_conn)

      _ ->
        IO.puts("Error: Unable to connect to DB.")
        :timer.sleep(1000)
        connect_loop()
    end
  end

  def handle_cast(message, state) do
    # spawn(fn -> send_to_pg(message) end)
    send_to_pg(message)

    {:noreply, state}
  end

  def send_to_pg(message) do
    message_decoded = Poison.decode!(message.message)
    timestamp = DateTime.utc_now()
    measure_value = Enum.random(1900..3000) / 100

    pg_query =
      "SELECT edata.insert_into_measure_value('#{timestamp}', '#{message_decoded["input_id"]}', '#{
        inspect(measure_value)
      }')"

    Postgrex.query!(:ToPg_Poolboy, pg_query, [], pool: DBConnection.Poolboy)
    # case Postgrex.query!(:ToPg_Poolboy, pg_query, [], pool: DBConnection.Poolboy) do
    #   {:ok, _} -> Agent.update(:to_pg_counter, &(&1 + 1))
    #   error -> IO.inspect error
    #   _ -> IO.puts("bad things happen...")
    # end

    Agent.update(:to_pg_counter, &(&1 + 1))
  end
end
