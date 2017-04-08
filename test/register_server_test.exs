defmodule RegisterServerTest do
  use PowerAssert
  import Masdb.Register.Server
  alias Masdb.Register
  alias Masdb.Schema

  setup context do
    {:ok, server} = Register.Server.start_link(context.test)
    {:ok, server: server}
  end

  test "added schemas are ordered", %{server: server} do
    force_become_synced(server)
    c0 = %Schema.Column{is_pk: true,  name: "c1", type: :int}
    s0 = %Schema{name: "foo", replication_factor: 0, columns: [c0]}
    s1 = %Schema{name: "bar", replication_factor: 0, columns: [c0]}

    add_schema(s0, server)
    add_schema(s1, server)
    result = get_schemas(server)

    assert Enum.at(result, 0).name == "bar"
    assert Enum.at(result, 1).name == "foo"
  end

  test "get_schema can return a schema or an error", %{server: server} do
    force_become_synced(server)
    c0 = %Schema.Column{is_pk: true,  name: "c1", type: :int}
    s0 = %Schema{name: "foo", replication_factor: 0, columns: [c0]}
    s1 = %Schema{name: "bar", replication_factor: 0, columns: [c0]}

    add_schema(s0, server)
    add_schema(s1, server)

    assert elem(get_schema("foo", server), 1).name == "foo"
    assert elem(get_schema("bar", server), 1).name == "bar"
    assert get_schema("baz", server) == :not_found
  end

  test "can't add schema if not synced", %{server: server} do
    c0 = %Schema.Column{is_pk: true,  name: "c1", type: :int}
    s0 = %Schema{name: "foo", replication_factor: 0, columns: [c0]}

    assert add_schema(s0, server) == :not_synced
    assert get_schemas(server) == []
  end
end
