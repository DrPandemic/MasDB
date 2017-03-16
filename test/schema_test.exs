defmodule SchemaTest do
  use PowerAssert
  import Masdb.Schema

  test "tests replication_factory limits" do
    assert validate(%Masdb.Schema{name: "foo", replication_factor: -1}) == :replication_factor_limits
  end
  
  test "tests primary_key_is_needed" do
    c1 = %Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}
    c2 = %Masdb.Schema.Column{is_pk: false, name: "c2", type: :int}
    c3 = %Masdb.Schema.Column{is_pk: false, name: "c3", type: :int}
  
    assert validate(%Masdb.Schema{name: "foo", replication_factor: 0, columns: [c1, c2, c3]}) == :ok
    assert validate(%Masdb.Schema{name: "foo", replication_factor: 1, columns: []})           == :primary_key_is_needed
    assert validate(%Masdb.Schema{name: "foo", replication_factor: 1, columns: [c2, c3]})     == :primary_key_is_needed
  end
end
