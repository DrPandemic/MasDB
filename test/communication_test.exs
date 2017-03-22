defmodule CommunicationTest do
  use PowerAssert
  import Masdb.Node.Communication

  test "select_quorum works on small lists" do
    assert select_quorum([]) == []
    node = Node.self
    assert select_quorum([node]) == [node]
  end

  test "select_quorum works on normal lists" do
    node0 = Node.self
    node1 = Node.self
    node2 = Node.self
    node3 = Node.self

    assert length(select_quorum([node0, node1])) == 2
    assert length(select_quorum([node0, node1, node2])) == 2
    assert length(select_quorum([node0, node1, node2, node3])) == 3
  end

  test "select_with_rest works with list" do
    node0 = :a
    node1 = :b
    node2 = :c
    node3 = :d

    {nodes0, rest0} = select_with_rest([node0, node1], 1)
    assert length(nodes0) == 1
    assert length(rest0) == 1
    assert nodes0 != rest0

    {nodes1, rest1} = select_with_rest([node0, node1, node2, node3], 1)
    assert length(nodes1) == 1
    assert length(rest1) == 3

    {nodes2, rest2} = select_with_rest([node0, node1, node2, node3], 4)
    assert length(nodes2) == 4
    assert length(rest2) == 0

    {nodes3, rest3} = select_with_rest([node0, node1, node2, node3], 2)
    assert length(nodes3) == 2
    assert length(rest3) == 2
    assert nodes3 != rest3
  end
  test "select_with_rest can be asked for more than it has" do
    node0 = :a

    {nodes0, rest0} = select_with_rest([node0], 2)
    assert length(nodes0) == 1
    assert length(rest0) == 0
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
