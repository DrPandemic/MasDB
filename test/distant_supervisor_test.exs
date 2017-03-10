defmodule DistantSupervisorTest do
  use PowerAssert
  import Masdb.Node.DistantSupervisor

  def sleep_random(min, max) do
    Process.sleep(Enum.random(min .. max))
  end

  def boom do
    raise "boom"
  end

  test "find_task_by_id works on empty list" do
    assert find_task_by_ref([], make_ref()) == nil
  end

  test "find_task_by_id returns the task" do
    t0 = Task.async(fn -> nil end)
    t1 = Task.async(fn -> nil end)
    t2 = Task.async(fn -> nil end)
    this = Node.self()

    assert find_task_by_ref([{this, t0}, {this, t1}, {this, t2}], t1.ref) == {this, t1}
  end

  test "find_task_by_id can return nil" do
    t0 = Task.async(fn -> nil end)
    t1 = Task.async(fn -> nil end)
    this = Node.self()

    assert find_task_by_ref([{this, t0}], t1.ref) == nil
  end

  test "get_process_for_nodes fetches pids" do
    assert query_remote_node(
      [Node.self(), Node.self()],
      Masdb.Node.DistantSupervisor,
      :get_local_pid_fn,
      [Masdb.Node],
      [timeout: 10]
    ) == [{Node.self(), Process.whereis(Masdb.Node)}, {Node.self(), Process.whereis(Masdb.Node)}]
  end

  test "get_process_for_nodes stops after the timeout" do
    assert length(query_remote_node(
          [Node.self(), Node.self(), Node.self(), Node.self(), Node.self()],
          __MODULE__,
          :sleep_random,
          [5, 20],
          [timeout: 10]
        )) <= 5
  end

  test "get_process_for_nodes can return an empty array" do
    assert query_remote_node(
      [Node.self(), Node.self(), Node.self(), Node.self(), Node.self()],
      __MODULE__,
      :sleep_random,
      [15, 20],
      [timeout: 10]
    ) == []
  end

  @tag :capture_log
  test "get_process_for_nodes can have crashed tasks" do
    assert query_remote_node(
      [Node.self()],
      __MODULE__,
      :boom,
      []
    ) == []
  end
end
