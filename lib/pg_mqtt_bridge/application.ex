defmodule PgMqttBridge.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: PgMqttBridge.Worker.start_link(arg)
      # {PgMqttBridge.Worker, arg},
      PgMqttBridge,
      PgMqttBridge.FromMqtt,
      PgMqttBridge.ToMqtt,
      PgMqttBridge.FromPg,
      PgMqttBridge.ToPg
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, max_restarts: 5, name: PgMqttBridge.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
