defmodule PgMqttBridge.ToMqtt do
  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: :to_mqtt)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast(message, _) do
    message_map = Poison.decode!(message)

    PgMqttBridge.ToMqtt.SendMqtt.send(
      message_map["topic"],
      Poison.encode!(message_map["payload"]),
      1,
      0
    )
  end

  defmodule SendMqtt do
    use Hulaaki.Client

    def send(topic, payload, qos, retain) do
      unless Process.whereis(:hulaaki_to) do
        {:ok, pid} = start_link(%{})
        Process.register(pid, :hulaaki_to)
        connect_loop(pid)
      end

      publish(
        :hulaaki_to,
        topic: topic,
        message: payload,
        dup: 0,
        qos: qos,
        retain: retain
      )

      {:noreply, []}
    end

    def connect_loop(pid) do
      mqtt_connection_string = Application.get_env(:pg_mqtt_bridge, PgMqttBridge.ToMqtt)
      conn = connect(pid, mqtt_connection_string)

      case conn do
        :ok ->
          IO.puts("Connected to Publish Broker.")
          conn

        _ ->
          IO.puts(
            "Error: Unable to connect to Publish Broker @ #{inspect(mqtt_connection_string)}."
          )

          :timer.sleep(1000)
          connect_loop(pid)
      end
    end
  end
end
