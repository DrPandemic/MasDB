defmodule HelperTest do
  use PowerAssert
  import Masdb.Helper

  test "find_task_by_id works on empty list" do
    assert find_task_by_ref([], make_ref()) == nil
  end

  test "find_task_by_id returns the task" do
    t0 = Task.async(fn -> nil end)
    t1 = Task.async(fn -> nil end)
    t2 = Task.async(fn -> nil end)

    assert find_task_by_ref([t0, t1, t2], t1.ref) == t1
  end

  test "find_task_by_id can return nil" do
    t0 = Task.async(fn -> nil end)
    t1 = Task.async(fn -> nil end)

    assert find_task_by_ref([t0], t1.ref) == nil
  end
end
