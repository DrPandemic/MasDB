defmodule SchemaTest do
  use PowerAssert
  import Masdb.Schema, only: [validate: 1]

  test "tests replication_factory limits" do
    assert validate(%Masdb.Schema{name: "foo", replication_factor: -1}) != :ok
    assert validate(%Masdb.Schema{name: "foo", replication_factor: 1}) == :ok
    assert validate(%Masdb.Schema{name: "foo", replication_factor: 0}) == :ok
  end

  test "can update timestamp" do
    schema0 = %Masdb.Schema{name: "foo", replication_factor: 1}
    Process.sleep 1
    schema1 = Masdb.Schema.update_timestamp(schema0)

    assert schema0.creation_time != schema1.creation_time
  end
end
