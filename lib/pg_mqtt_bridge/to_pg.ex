defmodule PgMqttBridge.ToPg do
  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: :to_pg)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast(message, state) do
    IO.puts(" >>> ToPg: " <> inspect(message))

    unless Process.whereis(:pg_conn) do
      {:ok, pid} = Postgrex.start_link(Application.get_env(:pg_mqtt_bridge, PgMqttBridge.FromPg))
      Process.register(pid, :pg_conn)
    end

    message_decoded = Poison.decode!(message.message)
    timestamp = DateTime.utc_now()

    Postgrex.query!(:pg_conn, "SELECT edata.insert_into_measure_value(
      '#{timestamp}',
      '#{message_decoded["input_id"]}',
      '#{inspect(message_decoded["measure_value"])}'
      )", [])

    {:noreply, state}
  end
end
