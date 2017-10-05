defmodule BonusTest do
  use ExUnit.Case
  doctest Bonus

  test "greets the world" do
    assert Bonus.hello() == :world
  end
end
