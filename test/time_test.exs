defmodule TimeTest do
  use PowerAssert
  import Masdb.Time

  test "returns a timestamp" do
    t0 = get_timestamp()
    t1 = get_timestamp()

    assert t0 <= t1
  end
end
