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

  test "quorum_size works" do
    assert quorum_size(0) == 0
    assert quorum_size(1) == 1
    assert quorum_size(2) == 2
    assert quorum_size(3) == 2
    assert quorum_size(9) == 5
    assert quorum_size(10) == 6
    assert quorum_size(11) == 6
  end

  test "has_quorum? works" do
    assert has_quorum?([], [])
    refute has_quorum?([], ["foo": :ok])
    refute has_quorum?([1], [])
    assert has_quorum?([1], ["foo": :ok])
    refute has_quorum?([1], ["foo": :not_ok])
    assert has_quorum?([1, 2], ["foo": :ok,"bar": :ok])
    refute has_quorum?([1, 2], ["foo": :ok])
    refute has_quorum?([1, 2], ["foo": :ok,"bar": :not_ok])
    refute has_quorum?([1, 2], ["foo": :ok,"bar": :ok,"baz": :ok])
    assert has_quorum?([1, 2, 3], ["foo": :ok,"bar": :ok,"baz": :ok])
    assert has_quorum?([1, 2, 3], ["foo": :ok,"bar": :ok])
    refute has_quorum?([1, 2, 3], ["foo": :ok])
  end
end
