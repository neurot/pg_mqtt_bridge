defmodule PgMqttBridge.ToPg do
  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: :to_pg)
  end

  def init(state) do
    connect_loop()
    {:ok, state}
  end

  def connect_loop() do
    connection_string = Application.get_env(:pg_mqtt_bridge, PgMqttBridge.FromPg)

    case Postgrex.start_link(connection_string) do
      {:ok, pid} ->
        IO.puts("Connected to DB.")
        Process.register(pid, :pg_conn)

      _ ->
        IO.puts("Error: Unable to connect to DB @ #{inspect(connection_string)}.")
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
    # timestamp = DateTime.utc_now()
    # measure_value = Enum.random(1900..3000) / 100
    # IO.puts timestamp
    # IO.inspect Date.to_string(message_decoded["timestamp"])

    Postgrex.query!(:pg_conn, "SELECT edata.insert_into_measure_value(
    '#{message_decoded["timestamp"]}',
    '#{message_decoded["input_id"]}',
    '#{inspect(message_decoded["measure_value"])}'
    )", [])
  end
end
