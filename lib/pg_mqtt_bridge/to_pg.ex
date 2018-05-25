defmodule PgMqttBridge.ToPg do
  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: :to_pg)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast(msg, state) do
    IO.puts("#{inspect(self())} -> Message received")
    IO.inspect(msg)
    {:noreply, state}
  end

  def tell(to) do
    GenServer.cast(to, "sali von #{inspect(self())}")
  end
end
