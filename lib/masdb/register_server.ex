defmodule Masdb.Register.Server do
  use GenServer
  require Logger

  alias Masdb.Register
  alias Masdb.Schema
  alias Masdb.Node.Communication
  alias Masdb.Node.DistantSupervisor
  alias Masdb.Register

  def start_link(name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, %Register{}, name: name)
  end

  def reset(name \\ __MODULE__) do
    GenServer.call(name, :reset)
  end

  def initial_add_schemas(schemas, name \\ __MODULE__) do
    GenServer.call(name, {:initial_add_schemas, schemas})
  end

  def add_schema(%Schema{} = schema, name \\ __MODULE__) do
    GenServer.call(name, {:add_schema, schema})
  end

  def received_add_schema(%Schema{} = schema, nodes, answers, from, name \\ __MODULE__) do
    GenServer.cast(name, {:received_add_schema, schema, nodes, answers, from})
  end

  def remote_add_schema(%Schema{} = schema, name \\ __MODULE__) do
    GenServer.call(name, {:remote_add_schema, schema})
  end

  def get_schemas(name \\ __MODULE__) do
    GenServer.call(name, :get_schemas)
  end

  def get_schema(schema_name, name \\ __MODULE__) do
    GenServer.call(name, {:get_schema, schema_name})
  end

  def get_state(name \\ __MODULE__) do
    GenServer.call(name, :get_state)
  end

  def received_gossip(gossip, name \\ __MODULE__) do
    GenServer.cast(name, {:gossip, gossip})
  end

  def is_synced(name \\ __MODULE__) do
    GenServer.call(name, :is_synced)
  end

  # For testing purposes
  def force_become_synced(name \\ __MODULE__) do
    GenServer.call(name, :force_become_synced)
  end

  # private
  def handle_call({:initial_add_schemas, schemas}, _, state) do
    {:reply, :ok, %Register{state| schemas: schemas, synced: true}}
  end

  def handle_call(:reset, _, _) do
    {:reply, :ok, %Register{}}
  end

  def handle_call(:get_schemas, _, %{schemas: schemas} = state) do
    {:reply, schemas, state}
  end

  def handle_call({:get_schema, schema_name}, _, %{schemas: schemas} = state) do
    case Enum.find(schemas, &(&1.name == schema_name)) do
      nil -> {:reply, :not_found, state}
      schema -> {:reply, {:ok, schema}, state}
    end
  end

  def handle_call(:force_become_synced, _, state) do
    {:reply, :ok, %Register{state | synced: true}}
  end

  def handle_call(:is_synced, _, state) do
    {:reply, state.synced, state}
  end

  def handle_call(params, from, state) do
    if state.synced do
      handle_synced_call(params, from, state)
    else
      {:reply, :not_synced, state}
    end
  end

  def handle_cast({:gossip, %Register{schemas: schemas}}, state) do
    {:noreply, %Register{state | schemas: Register.merge_schemas(state.schemas, schemas)}}
  end

  def handle_cast(params, state) do
    if state.synced do
      handle_synced_cast(params, state)
    else
      Logger.debug "The register server received a cast before being synced. " <> inspect(params)
      {:noreply, state}
    end
  end

  def handle_synced_cast({:received_add_schema, schema, nodes, answers, from}, state) do
    if Communication.has_quorum?(nodes, answers) do
      GenServer.reply(from, :ok)
      {:noreply, %Register{state | schemas: Schema.sort([schema | state.schemas])}}
    else
      GenServer.reply(from, :did_not_receive_quorum)
      {:noreply, state}
    end
  end

  def handle_synced_call({:add_schema, schema}, from, state) do
    schema = Schema.update_timestamp(schema)
    case Register.validate_new_schema(state.schemas, schema) do
      :ok ->
        this = self()
        # this could go in a supervisor
        spawn fn ->
          nodes = Masdb.Node.list()
          answers = DistantSupervisor.query_remote_nodes(
            nodes,
            Masdb.Register.Server,
            :remote_add_schema,
            [schema]
          )
          Register.Server.received_add_schema(schema, nodes, answers, from, this)
        end
        {:noreply, state}

      error -> {:reply, error, state}
    end
  end

  def handle_synced_call({:remote_add_schema, schema}, _, state) do
    case Register.validate_new_schema(state.schemas, schema) do
      :ok -> {:reply, :ok, %Register{state | schemas: Schema.sort([schema | state.schemas])}}
      error -> {:reply, error, state}
    end
  end

  def handle_synced_call(:get_state, _, state) do
    {:reply, state, state}
  end
end
