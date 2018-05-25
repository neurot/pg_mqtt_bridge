defmodule PgMqttBridgeTest do
  use ExUnit.Case
  doctest PgMqttBridge

  test "greets the world" do
    assert PgMqttBridge.hello() == :world
  end
end
