defmodule PgMqttBridge.FromPg do
  use Boltun, otp_app: :pg_mqtt_bridge

  def start_link(_) do
    PgMqttBridge.FromPg.start_link()
  end

  def init(state) do
    {:ok, state}
  end

  listen do
    channel("MQTT_PUBLISH", :on_mqtt_publish)
  end

  def on_mqtt_publish(_, notification) do
    spawn(fn -> send_to_to_mqtt(notification) end)
  end

  def send_to_to_mqtt(notification) do
    GenServer.cast(:to_mqtt, notification)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end
