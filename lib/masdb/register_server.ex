defmodule Masdb.Register.Server do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %Masdb.Register{}, name: __MODULE__)
  end

  def add_schema(%Masdb.Schema{} = schema) do
    GenServer.call(__MODULE__, {:add_schema, schema})
  end

  def get_schemas do
    GenServer.call(__MODULE__, :get_schemas)
  end

  # private
  def handle_call({:add_schema, schema}, _, state) do
    case Masdb.Register.validate_new_schema(state.schemas, schema) do
      :ok -> {:reply, :ok, %Masdb.Register{state | schemas: [schema | state.schemas]}}
      error -> {:reply, error, state}
    end
  end

  def handle_call(:get_schemas, _, %{schemas: schemas} = state) do
    {:reply, schemas, state}
  end
end
