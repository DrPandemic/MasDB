defmodule DistantSupervisorTest do
  use PowerAssert
  import Masdb.Node.DistantSupervisor

  test "can get local pid" do
    assert get_remote_pid_blocking(Node.self(), Masdb.Node) == Process.whereis(Masdb.Node)
  end
end
