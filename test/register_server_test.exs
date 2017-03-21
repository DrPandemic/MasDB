defmodule RegisterServerTest do
  use PowerAssert
  import Masdb.Register.Server

  setup context do
    {:ok, server} = Masdb.Register.Server.start_link(context.test)
    {:ok, server: server}
  end

  test "added schemas are ordered", %{server: server} do
    c0 = %Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}
    s0 = %Masdb.Schema{name: "foo", replication_factor: 0, columns: [c0]}
    s1 = %Masdb.Schema{name: "bar", replication_factor: 0, columns: [c0]}

    add_schema(s0, server)
    add_schema(s1, server)
    result = get_schemas()

    assert Enum.at(result, 0).name == "bar"
    assert Enum.at(result, 1).name == "foo"
  end
end
