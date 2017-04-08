defmodule RegisterServerDistributedTest do
  use PowerAssert
  import Masdb.Register.Server

  setup_all _ do
    DistributedEnv.stop()
    DistributedEnv.start(4)

    on_exit fn ->
      DistributedEnv.stop()
    end

    timer = Process.send_after(self(), :timeout, 2_000)

    wait_sync()

    Process.cancel_timer(timer)
    receive do
      :timedout -> :ok
    after
      0 -> :ok
    end
  end

  setup _ do
    :ok
  end

  def wait_sync do
    receive do
      :timedout -> raise "Was not able to sync nodes"
    after
      0 -> :ok
    end

    case GenServer.multi_call(Node.list(), Masdb.Register.Server, :is_synced) do
      {responses, []} -> if Enum.any?(responses, &(not elem(&1, 1))), do: wait_sync()
      _ -> wait_sync()
    end
  end

  test "distributed add_schema should produce enough duplication" do
    c0 = %Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}
    s0 = %Masdb.Schema{name: "foo", replication_factor: 0, columns: [c0]}

    assert add_schema(s0) != :not_synced
    assert Node.list()
      |> GenServer.multi_call(Masdb.Register.Server, :get_schemas)
      |> Tuple.to_list
      |> Enum.at(0)
      |> Keyword.values
      |> Enum.filter_map(&(length(&1) == 1), &(Enum.at(&1, 0)))
      |> Enum.count(&(&1.name == "foo")) >= Masdb.Node.Communication.quorum_size(length(Node.list()))
  end

  test "distributed add_schema should prevents inserting twice the same schema (on different nodes)" do
    c0 = %Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}
    s0 = %Masdb.Schema{name: "foo", replication_factor: 0, columns: [c0]}

    assert add_schema(s0) != :not_synced

    [{_, answer}] = Masdb.Node.DistantSupervisor.query_remote_nodes(
      [Enum.at(Node.list(), 0)],
      Masdb.Register.Server,
      :add_schema,
      [s0]
    )

    assert answer == :duplicate_name
  end
end
