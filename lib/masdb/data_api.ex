defmodule Masdb.Data.API do
  alias Masdb.Data
  alias Masdb.Node.DistantSupervisor

  def insert(schema_name, values, consistency, opts \\ [])
  def insert(schema_name, values, :quorum, opts) do
    with {:ok, local_row_id} <- Data.Server.insert(schema_name, values),
         {:ok, remote_answer} <- DistantSupervisor.query_remote_nodes_until() do
      {:ok, local_row_id, remote_answer}
    end

  end
  def insert(schema_name, values, consistency, opts) when consistency in [:unique, :multiple, :quorum, :all] do
    :not_implemented
  end
  def insert(_, _, _, _) do
    :unacceptable_consistency_level
  end
end
