defmodule TimestampTest do
  use PowerAssert
  import Masdb.Timestamp

  test "returns a timestamp" do
    t0 = get_timestamp()
    Process.sleep(5)
    t1 = get_timestamp()

    assert t0 <= t1
    assert t0 == t0
    assert t1 >= t0
  end
end
