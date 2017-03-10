defmodule Masdb.Node.DistantSupervisor do
  @max_timeout 1_000
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
    Task.Supervisor.async_nolink({Masdb.Node.DistantSupervisor, node}, module, fun, opts)
  end

  defp await_results(tasks) do
    timer = Process.send_after(self(), :timedout, @max_timeout)
    results = await_result(tasks, [], timer)
    cleanup(timer)
    results
  end

  defp await_result([], results, _), do: results
  defp await_result(tasks, results, timer_ref) do
    receive do
      {:timeout, ^timer_ref} ->
        IO.inspect :timeout
        {:timeout, results}

      # Task termination, can be caused by normal termination or crash
      {:DOWN, ref, _, pid, reason} when reason != :normal ->
        case Masdb.Helper.find_task_by_ref(tasks, ref) do
          nil ->
            await_result(tasks, results, timer_ref)
          _ ->
            await_result(List.delete(tasks, pid), results, timer_ref)
        end

      {ref, result} ->
        case Masdb.Helper.find_task_by_ref(tasks, ref) do
          nil ->
            await_result(tasks, results, timer_ref)
          task ->
            await_result(List.delete(tasks, task), [result | results], timer_ref)
        end

      _ ->
        await_result(tasks, results, timer_ref)
    end
  end

  defp cleanup(timer) do
    Process.cancel_timer(timer)
    receive do
      :timedout -> :ok
    after
      0 -> :ok
    end
  end
end
