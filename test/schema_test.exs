defmodule SchemaTest do
  use PowerAssert
  import Masdb.Schema

  test "get_pk works when single column pk" do
    c1 = %Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}
    c2 = %Masdb.Schema.Column{is_pk: false, name: "c2", type: :int}
    c3 = %Masdb.Schema.Column{is_pk: false, name: "c3", type: :int}

    schema = %Masdb.Schema{name: "foo", replication_factor: 0, columns: [c1, c2, c3]}
    assert Masdb.Schema.get_pk(schema) == ["c1"]
  end

  test "get_pk works when multi columns pk" do
    c1 = %Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}
    c2 = %Masdb.Schema.Column{is_pk: true, name: "c2", type: :int}
    c3 = %Masdb.Schema.Column{is_pk: false, name: "c3", type: :int}

    schema = %Masdb.Schema{name: "foo", replication_factor: 0, columns: [c1, c2, c3]}
    assert Masdb.Schema.get_pk(schema) == ["c1", "c2"]
  end

  test "get_non_nullables returns non nullable cols" do
    c1 = %Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}
    c2 = %Masdb.Schema.Column{is_pk: false, name: "c2", type: :int}
    c3 = %Masdb.Schema.Column{is_pk: false, name: "c3", type: :int, nullable: true}

    schema = %Masdb.Schema{name: "foo", replication_factor: 0, columns: [c1, c2, c3]}
    assert Masdb.Schema.get_non_nullables(schema) == ["c1", "c2"]
  end

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

  test "pks can't be nullable" do
    c1 = %Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int, nullable: true}
    assert validate(%Masdb.Schema{name: "foo", replication_factor: 0, columns: [c1]}) == :pk_cannot_be_nullable
  end

  test "can update timestamp" do
    schema0 = %Masdb.Schema{name: "foo", replication_factor: 1}
    Process.sleep 1
    schema1 = Masdb.Schema.update_timestamp(schema0)

    assert schema0.creation_time != schema1.creation_time
  end
end
