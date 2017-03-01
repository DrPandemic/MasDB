defmodule SchemaTest do
  use PowerAssert
  import Masdb.Schema, only: [validate: 1]

  test "tests replication_factory limits" do
    assert validate(%Masdb.Schema{name: "foo", replication_factor: -1}) != :ok
    assert validate(%Masdb.Schema{name: "foo", replication_factor: 1}) == :ok
    assert validate(%Masdb.Schema{name: "foo", replication_factor: 0}) == :ok
  end
end
