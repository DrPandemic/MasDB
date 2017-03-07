defmodule Masdb.Node.DistantSupervisor do
  def start_link do
    Task.Supervisor.start_link(name: Masdb.Node.DistantSupervisor)
  end

  def get_local_pid_fn(process) do
    Process.whereis(process)
  end

  def query_remote_node(nodes, module, fun, opts) do
    nodes
    |> Enum.map(&spawn_query(&1, module, fun, opts))
    |> await_results
  end

  defp spawn_query(node, module, fun, opts) do
    remote_task = Task.Supervisor.async({Masdb.Node.DistantSupervisor, node}, module, fun, opts)
    remote_task
  end

  defp await_results([tasks]) do
    Task.await tasks
  end

  defp await_result do
  end
end
