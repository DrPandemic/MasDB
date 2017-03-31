defmodule Masdb.Initializer do
  def start_link do
    {:ok, spawn_link(__MODULE__, :initialize_node, [])}
  end

  def initialize_node do
    nodes = Masdb.Node.list()
    {:ok, answers} = Masdb.Node.DistantSupervisor.query_remote_nodes_until(
      nodes,
      Masdb.Register.Server,
      :get_schemas,
      [],
      Masdb.Node.Communication.quorum_size(length(nodes))
    )

    schemas = merge_answers(answers)

    Masdb.Register.Server.initial_add_schemas(schemas)

    :ok
  end

  def merge_answers(answers, schemas \\ [])
  def merge_answers([], schemas), do: schemas
  def merge_answers([{_, schemas}|tail], new_schemas) do
    merge_answers(tail, Masdb.Register.merge_schemas(schemas, new_schemas))
  end
end
