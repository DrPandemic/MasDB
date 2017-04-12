defmodule Masdb.Data.Server do
  use GenServer
  alias Masdb.Data
  alias Masdb.Register
  alias Masdb.Timestamp

  def start_link(register \\ Register.Server, name \\ __MODULE__) do
    GenServer.start_link(__MODULE__,
      {
        register,
        %Data.Map{
          node_id: inspect(Node.self),
          last_update_time: Timestamp.get_timestamp()
        }},
      name: name
    )
  end

  def init(state) do
   {:ok, state}
  end

  def insert(schema_name, values, name \\ __MODULE__) do
    GenServer.call(name, {:insert, schema_name, values})
  end

  # private
  def handle_call(params, from, {register, %Data.Map{}} = state) do
    # since this is blocking, it could cause issues
    if Register.Server.is_synced(register) do
      handle_synced_call(params, from, state)
    else
      {:reply, :not_synced, state}
    end
  end

  def handle_synced_call({:insert, schema_name, values}, _, {register, state}) do
    result =
      with {:ok, schema} <- Register.Server.get_schema(schema_name, register) do
        Data.Map.insert(state, schema, values)
      end

    case result do
      {:ok, row_id, new_state} -> {:reply, {:ok, row_id}, {register, new_state}}
      error -> {:reply, error, {register, state}}
    end
  end
end
