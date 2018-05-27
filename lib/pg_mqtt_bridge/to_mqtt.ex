defmodule PgMqttBridge.ToMqtt do
  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: :to_mqtt)
  end

  def init(state) do
    PgMqttBridge.ToMqtt.SendMqtt.init()
    {:ok, state}
  end

  def handle_cast(message, _) do
    spawn(fn -> PgMqttBridge.ToMqtt.SendMqtt.send(message) end)
    {:noreply, []}
  end

  defmodule SendMqtt do
    use Hulaaki.Client

    def init() do
      {:ok, pid} = start_link(%{})
      Process.register(pid, :hulaaki_to)
      connect_loop(pid)
    end

    def send(message) do
      message_map = Poison.decode!(message)

      publish(
        :hulaaki_to,
        topic: message_map["topic"],
        message: Poison.encode!(message_map["payload"]),
        dup: 0,
        qos: 1,
        retain: 0
      )
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
