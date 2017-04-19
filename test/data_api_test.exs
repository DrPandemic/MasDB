defmodule DataAPITest do
  use PowerAssert
  import Masdb.Data.API
  alias Masdb.Schema
  alias Masdb.Register

  setup context do
    {:ok, register} = Register.Server.start_link(context.test)
    {:ok, data_server} = Masdb.Data.Server.start_link(
      context.test,
      String.to_atom(Atom.to_string(context.test) <> " data_server")
    )
    Register.Server.force_become_synced(register)
    [register: register, data_server: data_server]
  end

  test "insert can only be called with predefined consistency levels",
    %{register: register, data_server: data_server} do
    c0 = %Schema.Column{is_pk: true,  name: "c1", type: :int}
    s0 = %Schema{name: "foo", replication_factor: 0, columns: [c0]}
    Register.Server.add_schema(s0, register)

    opts = [
      timeout: 10,
      nodes: [],
      data_server: data_server,
      fetch_fn: fn(_, _, _, _, _) -> [] end
    ]

    levels = [unique: 0, multiple: 1, quorum: 2, all: 3]

    for {l, i} <- levels, do: insert("foo", %{"c1" => i}, l, opts)

    assert insert("foo", %{"c1" => 0}, :foo) == :unacceptable_consistency_level
  end

  test "insert :unique doesn't perform a remote query",
    %{register: register} do
    c0 = %Schema.Column{is_pk: true,  name: "c1", type: :int}
    s0 = %Schema{name: "foo", replication_factor: 0, columns: [c0]}
    Register.Server.add_schema(s0, register)
    this = self()
    opts = [
      timeout: 10,
      fetch_fn: fn(_, _, _, _, _) -> send this, :fetched end
    ]

    insert("foo", %{"c1" => 0}, :unique, opts)

    refute_received :fetched
  end

  test "insert :quorum can succeed",
    %{register: register, data_server: data_server} do
    c0 = %Schema.Column{is_pk: true,  name: "c1", type: :int}
    s0 = %Schema{name: "foo", replication_factor: 0, columns: [c0]}
    Register.Server.add_schema(s0, register)

    opts = [
      timeout: 10,
      nodes: [:foo, :bar, :baz, :wow, :idea],
      data_server: data_server,
      fetch_fn: fn(_, _, _, _, _) -> [foo: {:ok, 1}, bar: {:ok, 1}, baz: {:ok, 1}] end
    ]

    {flag, _} = insert("foo", %{"c1" => 0}, :quorum, opts)

    assert flag == :ok
  end

  test "insert :quorum fails when the schema doesn't exist",
    %{data_server: data_server} do
    opts = [
      timeout: 10,
      nodes: [:foo, :bar, :baz, :wow, :idea],
      data_server: data_server,
      fetch_fn: fn(_, _, _, _, _) -> [foo: {:ok, 1}, bar: {:ok, 1}, baz: {:ok, 1}] end
    ]

    assert insert("foo", %{"c1" => 0}, :quorum, opts) == :not_found
  end

  test "validate_remote_insert should only pass if all success" do
    assert validate_remote_insert([]) == :ok
    assert validate_remote_insert([a: {:ok, 1}]) == :ok
    assert validate_remote_insert([a: {:ok, 1}, b: {:ok, 1}]) == :ok
    assert validate_remote_insert([a: {:ok, 1}, b: :cannot_insert_empty_row]) == :refused_modification
  end
end
