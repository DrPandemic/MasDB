defmodule DistantSupervisorTest do
  use PowerAssert
  import Masdb.Node.DistantSupervisor

  def sleep_random(min, max) do
    Process.sleep(Enum.random(min .. max))
  end

  def boom do
    raise "boom"
  end

  def foo do
    :bar
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
    assert query_remote_nodes(
      [Node.self(), Node.self()],
      Masdb.Node.DistantSupervisor,
      :get_local_pid_fn,
      [Masdb.Node],
      [timeout: 10]
    ) == [{Node.self(), Process.whereis(Masdb.Node)}, {Node.self(), Process.whereis(Masdb.Node)}]
  end

  test "get_process_for_nodes stops after the timeout" do
    assert length(query_remote_nodes(
          [Node.self(), Node.self(), Node.self(), Node.self(), Node.self()],
          __MODULE__,
          :sleep_random,
          [5, 20],
          [timeout: 10]
        )) <= 5
  end

  test "get_process_for_nodes can return an empty array" do
    assert query_remote_nodes(
      [Node.self(), Node.self(), Node.self(), Node.self(), Node.self()],
      __MODULE__,
      :sleep_random,
      [15, 20],
      [timeout: 10]
    ) == []
  end

  @tag :capture_log
  test "get_process_for_nodes can have crashed tasks" do
    assert query_remote_nodes(
      [Node.self()],
      __MODULE__,
      :boom,
      []
    ) == []
  end

  test "query_remote_nodes_until returns an error if to many responses are asked" do
    opts = [
      timeout: 10,
      fetch_fn: fn(_, _, _, _, _) -> [] end
    ]

    assert query_remote_nodes_until([], __MODULE__, :foo, [], 1, [], opts) == :not_enough_nodes
  end

  test "query_remote_nodes_until returns when enough answers are fetched" do
    opts = [
      timeout: 10,
      fetch_fn: fn(_, _, _, _, _) -> [foo: "yup", bar: "yes"] end
    ]

    {:ok, answers} = query_remote_nodes_until([:foo, :bar, :baz], __MODULE__, :foo, [], 2, [], opts)

    assert length(answers) == 2
  end

  test "query_remote_nodes_until returns when enough answers are fetched with multiple calls on fetch_fun" do
    opts = [
      timeout: 10,
      fetch_fn: fn(nodes, _, _, _, _) ->
        case nodes do
          [a] -> [{a, "wow"}]
          [a, _] -> [{a, "yup"}]
        end
      end
    ]

    {:ok, answers} = query_remote_nodes_until([:foo, :bar, :baz], __MODULE__, :foo, [], 2, [], opts)

    assert length(answers) == 2
  end

  test "query_remote_nodes_until returns an error after many calls not returning enough answers" do
    opts = [
      timeout: 10,
      fetch_fn: fn(nodes, _, _, _, _) ->
        case nodes do
          [_] -> []
          [a, _] -> [{a, "yup"}]
        end
      end
    ]

    assert query_remote_nodes_until([:foo, :bar, :baz], __MODULE__, :foo, [], 2, [], opts) == :not_enough_nodes
  end
end
