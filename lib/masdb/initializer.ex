defmodule Masdb.Initializer do
  alias Masdb.Node.DistantSupervisor
  alias Masdb.Node.Communication
  alias Masdb.Register

  def start_link do
    {:ok, spawn_link(__MODULE__, :initialize_node, [])}
  end

  def initialize_node do
    nodes = Masdb.Node.list()
    {:ok, answers} = DistantSupervisor.query_remote_nodes_until(
      nodes,
      Register.Server,
      :get_schemas,
      [],
      Communication.quorum_size(length(nodes))
    )

    schemas = merge_answers(answers)

    Register.Server.initial_add_schemas(schemas)

    :ok
  end

  def merge_answers(answers, schemas \\ [])
  def merge_answers([], schemas), do: schemas
  def merge_answers([{_, schemas}|tail], new_schemas) do
    merge_answers(tail, Register.merge_schemas(schemas, new_schemas))
  end
end
