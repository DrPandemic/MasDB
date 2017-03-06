defmodule CommunicationTest do
  use PowerAssert
  import Masdb.Node.Communication

  test "select_qorum works on small lists" do
    assert select_quorum([]) == []
    pid = :c.pid(0,1,2)
    assert select_quorum([pid]) == [pid]
  end

  test "select_qorum works on normal lists" do
    pid0 = :c.pid(0,1,0)
    pid1 = :c.pid(0,1,1)
    pid2 = :c.pid(0,1,2)
    pid3 = :c.pid(0,1,3)

    assert length(select_quorum([pid0, pid1])) == 2
    assert length(select_quorum([pid0, pid1, pid2])) == 2
    assert length(select_quorum([pid0, pid1, pid2, pid3])) == 3
  end
end
