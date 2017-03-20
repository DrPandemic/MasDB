defmodule Masdb.Register.Server do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %Masdb.Register{}, name: __MODULE__)
  end

  def add_schema(%Masdb.Schema{} = schema) do
    GenServer.call(__MODULE__, {:add_schema, schema})
  end

  def received_add_schema(%Masdb.Schema{} = schema, nodes, answers, from) do
    GenServer.cast(__MODULE__, {:received_add_schema, schema, nodes, answers, from})
  end

  def remote_add_schema(%Masdb.Schema{} = schema) do
    GenServer.call(__MODULE__, {:remote_add_schema, schema})
  end

  def get_schemas do
    GenServer.call(__MODULE__, :get_schemas)
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def received_gossip(gossip) do
    GenServer.cast(__MODULE__, {:gossip, gossip})
  end

  # private
  def handle_cast({:received_add_schema, schema, nodes, answers, from}, state) do
    if Masdb.Node.Communication.has_quorum?(nodes, answers) do
      GenServer.reply(from, :ok)
      {:noreply, %Masdb.Register{state | schemas: [schema | state.schemas]}}
    else
      GenServer.reply(from, :did_not_receive_quorum)
      {:noreply, state}
    end
  end

  def handle_cast({:gossip, %Masdb.Register{schemas: schemas}}, state) do
    {:noreply, %Masdb.Register{state | schemas: Masdb.Register.merge_schemas(state.schemas, schemas)}}
  end

  def handle_call({:add_schema, schema}, from, state) do
    schema = Masdb.Schema.update_timestamp(schema)
    case Masdb.Register.validate_new_schema(state.schemas, schema) do
      :ok ->
        spawn fn ->
          nodes = Masdb.Node.Connection.list()
          a = Masdb.Node.DistantSupervisor.query_remote_node(nodes, Masdb.Register.Server, :remote_add_schema, [schema])
          Masdb.Register.Server.received_add_schema(schema, nodes, a, from)
        end
        {:noreply, state}

      error -> {:reply, error, state}
    end
  end

  def handle_call({:remote_add_schema, schema}, _, state) do
    case Masdb.Register.validate_new_schema(state.schemas, schema) do
      :ok -> {:reply, :ok, %Masdb.Register{state | schemas: [schema | state.schemas]}}
      error -> {:reply, error, state}
    end
  end

  def handle_call(:get_schemas, _, %{schemas: schemas} = state) do
    {:reply, schemas, state}
  end

  def handle_call(:get_state, _, state) do
    {:reply, state, state}
  end
end
