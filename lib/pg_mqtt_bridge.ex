defmodule PgMqttBridge do
  use GenServer

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def init(state) do
    IO.puts("Starting PgMqttBridge...")
    {:ok, state}
  end
end
