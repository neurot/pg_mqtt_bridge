defmodule PgMqttBridge.ToPg do
  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: :to_pg)
  end

  def init(state) do
    {:ok, state}
  end

  def connect_loop() do
    connection_string = Application.get_env(:pg_mqtt_bridge, PgMqttBridge.FromPg)

    try do
      IO.inspect(Postgrex.start_link(connection_string))

      case Postgrex.start_link(connection_string) do
        {:ok, pid} ->
          IO.puts("Connected to DB.")
          Process.register(pid, :pg_conn)

        _ ->
          IO.puts("Error: Unable to connect to DB @ #{inspect(connection_string)}.")
          :timer.sleep(5000)
          connect_loop()
      end
    catch
      :terminating, _ -> IO.puts("@@@@@@@@@@@@@@@@@@@@@")
      _, msg -> IO.puts("@@@@@@@@@@@@@@@@@@@@@")
    end
  end

  def send_to_pg(message) do
    message_decoded = Poison.decode!(message.message)
    timestamp = DateTime.utc_now()
    measure_value = Enum.random(1900..3000) / 100

    Postgrex.query!(:pg_conn, "SELECT edata.insert_into_measure_value(
    '#{timestamp}',
    '#{message_decoded["input_id"]}',
    '#{inspect(measure_value)}'
    )", [])
  end

  def handle_cast(message, state) do
    unless Process.whereis(:pg_conn) do
      connect_loop()
    end

    spawn(fn -> send_to_pg(message) end)

    {:noreply, state}
  end
end
