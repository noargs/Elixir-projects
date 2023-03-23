defmodule HiSupervisorTest do
  use ExUnit.Case
  doctest HiSupervisor

  test "greets the world" do
    assert HiSupervisor.hello() == :world
  end
end
