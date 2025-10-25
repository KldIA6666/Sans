defmodule SansTest do
  use ExUnit.Case
  doctest Sans

  test "greets the world" do
    assert Sans.hello() == :world
  end
end
