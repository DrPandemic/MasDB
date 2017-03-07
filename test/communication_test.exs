defmodule CommunicationTest do
  use PowerAssert
  import Masdb.Node.Communication

  test "select_quorum works on small lists" do
    assert select_quorum([]) == []
    node = Node.self
    assert select_quorum([node]) == [node]
  end

  test "select_qorum works on normal lists" do
    node0 = Node.self
    node1 = Node.self
    node2 = Node.self
    node3 = Node.self

    assert length(select_quorum([node0, node1])) == 2
    assert length(select_quorum([node0, node1, node2])) == 2
    assert length(select_quorum([node0, node1, node2, node3])) == 3
  end

  test "get_process_for_nodes fetches pids" do
    this = self()
    baz = fn(node, _) ->
      Task.async(fn ->
        send this, node
        node
      end)
    end

    ls = [:foo, :bar]
    assert get_process_for_nodes(ls, :baz, baz) == ls
    assert_received :foo
    assert_received :bar
  end
end
