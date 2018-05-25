defmodule PgMqttBridge.ToMqtt do
  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: :to_mqtt)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast(message, _) do
    IO.puts(" >>> ToMqtt: " <> inspect(message))
    message_map = Poison.decode!(message)

    PgMqttBridge.ToMqtt.SendMqtt.send(
      message_map["topic"],
      Poison.encode!(message_map["payload"]),
      0,
      0
    )
  end

  defmodule SendMqtt do
    use Hulaaki.Client

    def send(topic, payload, qos, retain) do
      unless Process.whereis(:hulaaki) do
        {:ok, pid} = start_link(%{})
        connect(pid, Application.get_env(:pg_mqtt_bridge, PgMqttBridge.MqttConn))
        Process.register(pid, :hulaaki)
      end

      publish(
        :hulaaki,
        topic: topic,
        message: payload,
        dup: 0,
        qos: qos,
        retain: retain
      )

      {:noreply, []}
    end
  end
end
