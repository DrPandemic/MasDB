defmodule Masdb.Node.DistantSupervisor do
  alias Masdb.Node.Communication

  def start_link do
    Task.Supervisor.start_link(name: Masdb.Node.DistantSupervisor)
  end

  def get_local_pid_fn(process) do
    Process.whereis(process)
  end

  def find_task_by_ref(tasks, ref) when is_reference(ref) do
    Enum.find(tasks, fn t -> elem(t, 1).ref == ref end)
  end

  @spec query_remote_nodes_until([atom], atom, atom, [any], integer, keyword, keyword) :: {:ok, keyword} | atom
  def query_remote_nodes_until(nodes, module, fun, params, min, answers \\ [], opts \\ [])
  # enough responses
  def query_remote_nodes_until(_, _, _, _, min, answers, _)
  when length(answers) >= min do
    {:ok, answers}
  end

  # even with all nodes left, we can't reach the minimum
  def query_remote_nodes_until(nodes, _, _, _, min, answers, _)
  when length(nodes) + length(answers) < min do
    :not_enough_nodes
  end

  # get shit done
  def query_remote_nodes_until(nodes, module, fun, params, min, answers, opts) do
    {nodes, rest} = Communication.select_with_rest(nodes, min)
    fetch_fun = opts[:fetch_fn] || (fn(nodes, module, fun, params, opts) ->
      nodes
      |> Enum.map(&spawn_query(&1, module, fun, params))
      |> await_results(opts)
    end)

    answers = answers ++ fetch_fun.(nodes, module, fun, params, opts)

    query_remote_nodes_until(rest, module, fun, params, min, answers, opts)
  end

  def query_remote_nodes(nodes, module, fun, params, opts \\ []) do
    nodes
    |> Enum.map(&spawn_query(&1, module, fun, params))
    |> await_results(opts)
  end

  defp spawn_query(destination, module, fun, params) do
    {destination, Task.Supervisor.async_nolink({Masdb.Node.DistantSupervisor, destination}, module, fun, params)}
  end

  defp await_results(tasks, opts) do
    timeout = opts[:timeout] || Application.get_env(:masdb, :"distant_task_timeout")
    timer = Process.send_after(self(), :timeout, timeout)
    results = await_result(tasks, [], timer)
    cleanup(timer)
    results
  end

  defp await_result([], results, _), do: results
  defp await_result(tasks, results, timer_ref) do
    receive do
      :timeout ->
        results

      # Task termination, can be caused by normal termination or crash
      {:DOWN, ref, _, _, reason} when reason != :normal ->
        case find_task_by_ref(tasks, ref) do
          nil ->
            await_result(tasks, results, timer_ref)
          {_, task} ->
            await_result(List.delete(tasks, task), results, timer_ref)
        end

      {ref, result} ->
        case find_task_by_ref(tasks, ref) do
          nil ->
            await_result(tasks, results, timer_ref)
          {sender, task} ->
            await_result(List.delete(tasks, task), [{sender, result} | results], timer_ref)
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
