defmodule PgMqttBridge.FromMqtt do
  use Hulaaki.Client

  def init(state) do
    {:ok, pid} = start_link(%{})
    Process.register(pid, :hulaaki_from)
    connect_loop(pid)
    subscriptions = [topics: ["dataservice/input"], qoses: [1]]
    subscribe(:hulaaki_from, subscriptions)
    {:ok, state}
  end

  def connect_loop(pid) do
    mqtt_connection_string = Application.get_env(:pg_mqtt_bridge, PgMqttBridge.FromMqtt)
    conn = connect(pid, mqtt_connection_string)

    case conn do
      :ok ->
        IO.puts("Connected to Subscription Broker.")
        conn

      _ ->
        IO.puts("Error: Unable to connect to Subscription Broker.")
        :timer.sleep(1000)
        connect_loop(pid)
    end
  end

  def on_subscribed_publish(mqtt_message) do
    [head | _] = mqtt_message
    message = elem(head, 1)
    GenServer.cast(:to_pg, message)
  end
end
