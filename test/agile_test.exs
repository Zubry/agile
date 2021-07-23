defmodule AgileTest do
  use ExUnit.Case
  doctest Agile

  test "greets the world" do
    assert Agile.hello() == :world
  end
end
