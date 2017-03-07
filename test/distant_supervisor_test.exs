defmodule DistantSupervisorTest do
  use PowerAssert
  import Masdb.Node.DistantSupervisor

  test "get_process_for_nodes fetches pids" do
    assert query_remote_node(
      [Node.self()],
      Masdb.Node.DistantSupervisor,
      :get_local_pid_fn,
      [Masdb.Node]
    ) == Process.whereis(Masdb.Node)
  end
end
