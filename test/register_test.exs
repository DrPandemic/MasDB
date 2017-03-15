defmodule ResgisterTest do
  use PowerAssert
  import Masdb.Register, only: [validate_new_schema: 2]

  test "can work" do
    assert validate_new_schema(
      [%Masdb.Schema{name: "foo", replication_factor: 1}],
      %Masdb.Schema{name: "bar", replication_factor: 2}
    ) == :ok
  end

  test "tests name collisions" do
    assert validate_new_schema(
      [%Masdb.Schema{name: "foo", replication_factor: 1}],
      %Masdb.Schema{name: "foo", replication_factor: 2}
    ) == :duplicate_name
  end

  test "tests replication_factory limits" do
    assert validate_new_schema(
      [],
      %Masdb.Schema{name: "foo", replication_factor: -1}
    ) != :ok
  end

  test "tests that an older schema could overwrite a schema" do
    d0 = Masdb.Timestamp.get_timestamp()
    Process.sleep 1
    d1 = Masdb.Timestamp.get_timestamp()

    assert validate_new_schema(
      [%Masdb.Schema{name: "foo", replication_factor: 1, creation_time: d1}],
      %Masdb.Schema{name: "foo", replication_factor: 1, creation_time: d0}
    ) == :ok
  end
end
