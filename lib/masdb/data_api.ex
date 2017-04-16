defmodule Masdb.Data.API do
  alias Masdb.Data
  alias Masdb.Node.DistantSupervisor
  alias Masdb.Node.Communication

  @spec insert(String.t, map, atom, keyword) :: {:ok, integer} | atom
  def insert(schema_name, values, consistency, opts \\ [])
  def insert(schema_name, values, :quorum, opts) do
    with {:ok, local_row_id} <- Data.Server.insert(schema_name, values, opts[:data_server]),
         nodes <- opts[:nodes] || Masdb.Node.list(),
         {:ok, remote_answers} <- DistantSupervisor.query_remote_nodes_until(nodes, Masdb.Data.Server, :insert,
           [schema_name, values], Communication.quorum_size(length(nodes)), [], opts),
         :ok <- validate_remote_insert(remote_answers) do
      {:ok, local_row_id}
    end

  end
  def insert(_, _, consistency, _) when consistency in [:unique, :multiple, :quorum, :all] do
    :not_implemented
  end
  def insert(_, _, _, _) do
    :unacceptable_consistency_level
  end

  @spec validate_remote_insert(keyword) :: :ok | atom
  def validate_remote_insert([]), do: :ok
  def validate_remote_insert([{_, head}|tail]) do
    case head do
      {:ok, _} -> validate_remote_insert(tail)
      _ -> :refused_modification
    end
  end
end
