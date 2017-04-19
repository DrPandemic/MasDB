defmodule DataServerTest do
  use PowerAssert
  import Masdb.Data.Server
  alias Masdb.Register
  alias Masdb.Data

  setup context do
    {:ok, register} = Register.Server.start_link(context.test)
    {:ok, data_server} = Data.Server.start_link(
      context.test,
      String.to_atom(Atom.to_string(context.test) <> " data_server")
    )
    Register.Server.force_become_synced(register)
    [register: register, data_server: data_server]
  end

  test "insert waits for the register to be synced" do
    {:ok, _} = Register.Server.start_link(:foo)
    {:ok, data_server} = start_link(:foo, :bar)

    assert insert("foo", [], data_server) == :not_synced
  end
end
