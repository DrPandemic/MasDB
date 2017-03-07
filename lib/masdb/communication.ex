defmodule Masdb.Node.Communication do
  def select_quorum(nodes) do
    Enum.take_random(nodes, Integer.floor_div(length(nodes), 2) + 1)
  end

  def get_process_for_nodes(
    nodes,
    process,
    get_remote \\ &Masdb.Node.DistantSupervisor.get_remote_pid/2) do
    nodes
    |> Enum.map(fn node ->
      get_remote.(
        node,
        process
      ) end)
    |> Enum.map(&Task.await/1)
  end
end
