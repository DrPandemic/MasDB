defmodule ResgisterTest do
  use PowerAssert
  import Masdb.Register, only: [validate_new_schema: 2]

  test "can work" do
    assert validate_new_schema(
      [%Masdb.Schema{name: "foo", replication_factor: 1}],
      %Masdb.Schema{name: "bar", replication_factor: 2, columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: "int"}]}
    ) == :ok
  end

  test "tests name collisions" do
    assert validate_new_schema(
      [%Masdb.Schema{name: "foo", replication_factor: 1}],
      %Masdb.Schema{name: "foo", replication_factor: 2, columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: "int"}]}
    ) == :duplicate_name
  end

  test "tests replication_factory limits" do
    assert validate_new_schema(
      [],
      %Masdb.Schema{name: "foo", replication_factor: -1}
    ) != :ok
  end
end
