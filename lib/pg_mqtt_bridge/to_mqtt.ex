defmodule PgMqttBridge.ToMqtt do
  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: :to_mqtt)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast(message, state) do
    PgMqttBridge.ToMqtt.SendMqtt.send(message, state)
  end

  defmodule SendMqtt do
    use Hulaaki.Client

    def send(message, state) do
      unless Process.whereis(:hulaaki_pub) do
        {:ok, pid} = start_link(%{})
        connect(pid, Application.get_env(:pg_mqtt_bridge, PgMqttBridge.ToMqtt))
        Process.register(pid, :hulaaki_pub)
      end

      message_map = Poison.decode!(message)
      IO.inspect(message_map["topic"])
      IO.inspect(message_map["payload"])

      publish(
        :hulaaki_pub,
        topic: message_map["topic"],
        message: Poison.encode!(message_map["payload"]),
        dup: 0,
        qos: 1,
        retain: 1
      )

      {:noreply, state}
    end
  end
end
