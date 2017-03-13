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
end
