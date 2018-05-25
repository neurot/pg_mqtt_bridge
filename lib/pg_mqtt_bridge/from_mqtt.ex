defmodule PgMqttBridge.FromMqtt do
  use Hulaaki.Client

  def init(state) do
    {:ok, pid} = start_link(%{})
    connect(pid, Application.get_env(:pg_mqtt_bridge, PgMqttBridge.MqttConn))
    Process.register(pid, :hulaaki)
    subscriptions = [topics: ["dataservice/input"], qoses: [1]]
    subscribe(:hulaaki, subscriptions)
    {:ok, state}
  end

  def on_subscribed_publish(mqtt_message) do
    # IO.puts(" >>> FromMqtt: " <> inspect(DateTime.utc_now()))
    [head | _] = mqtt_message
    message = elem(head, 1)
    GenServer.cast(:to_pg, message)
  end
end
