defmodule Masdb.Data.Val do
  @type time :: Masdb.Timestamp.t
  @type value :: integer | float | boolean | String.t | :unknown
  
  @type t :: %Masdb.Data.Val{
    since_ts: time,
    value: value,
  }
  @enforce_keys [:since_ts, :value]
  defstruct [:since_ts, :value]
end

defmodule Masdb.Data.Row do
  @type col_name :: String.t
  @type columns :: %{optional(col_name) => list(Masdb.Data.Val.t)}

  @type t :: %Masdb.Data.Row{columns: columns}
  @enforce_keys []
  defstruct [columns: %{}]
end

defmodule Masdb.Data.Table do
  @type row_id :: String.t
  @type rows :: %{optional(row_id) => Masdb.Data.Row.t}

  @type t :: %Masdb.Data.Table{rows: rows}
  @enforce_keys []
  defstruct [rows: %{}]
end

defmodule Masdb.Data.Map do
  use Pipe

  @type schema_name :: String.t
  @type node_id :: String.t
  @type time :: Masdb.Timestamp.t
  @type opened_time :: time | nil
  @type data_map :: %{optional(schema_name) => Masdb.Data.Table.t}

  @type t :: %Masdb.Data.Map{
    node_id: node_id,
    last_update_time: time,
    last_sync_time: opened_time,
    map: data_map
  }
  @enforce_keys [:node_id, :last_update_time]
  defstruct [:node_id, :last_update_time, last_sync_time: nil, map: %{}]

  def insert(%Masdb.Data.Map{ node_id: n_id, last_sync_time: l_s_t, map: old_map }, schema, values) do
    timestamp = Masdb.Timestamp.get_timestamp()
    row_id = n_id <> to_string(timestamp.unique_integer)
    old_rows = Map.get(old_map, schema.name, %Masdb.Data.Table{}).rows
    pks = Masdb.Schema.get_pks(schema)
    non_nullables = Masdb.Schema.get_non_nullables(schema)

    {row_id, pipe_matching({:ok, _},
              {:ok, values}
              |> validate_with_schema(schema)
              |> validate_nullable_referenced(non_nullables)
              |> validate_pk_uniqueness(old_rows, pks)
              |> normalize_to_row(timestamp)
              |> put_new_row(schema.name, row_id, n_id, l_s_t, old_map, timestamp))}
  end

  defp validate_with_schema({:ok, values}, schema) do
    keys = Map.keys(values)
    case length(keys) do
      0 -> {:cannot_insert_empty_row, values}
      _ -> {validate_col_exists(keys, schema), values}
    end
  end

  defp validate_nullable_referenced(values, []) do
    values
  end

  defp validate_nullable_referenced({:ok, values}, [nn_nullable | tail]) do
    case Map.get(values, nn_nullable) do
      nil -> {:non_nullable_not_referenced, values}
        _ -> validate_nullable_referenced({:ok, values}, tail)
    end
  end

  defp validate_pk_uniqueness({:ok, values}, rows, pks) do
    case Enum.find(Map.values(rows), &(row_has_same_pk?(&1, values, pks))) do
      nil -> {:ok, values}
        _ -> {:duplicate_pk, values}
    end
  end

  defp normalize_to_row({:ok, values}, timestamp) do
    {:ok, %Masdb.Data.Row{columns: normalize_to_vals(values, Map.keys(values), timestamp)}}
  end

  defp put_new_row({:ok, row}, schema_name, row_id, node_id, last_sync_time, old_map, timestamp) do
    {:ok, %Masdb.Data.Map{
            node_id: node_id,
            last_update_time: timestamp,
            last_sync_time: last_sync_time,
            map: Map.update(old_map, 
                            schema_name, 
                            %Masdb.Data.Table{rows: %{row_id => row}}, 
                            &(%Masdb.Data.Table{rows: Map.put_new(&1.rows, row_id, row)}))
    }}
  end

  defp validate_col_exists([], _) do
    :ok
  end

  defp validate_col_exists([col | tail], schema) do
    case Enum.find(schema.columns, fn c -> c.name == col end) do
      nil -> :col_doesnt_exists
      _ -> validate_col_exists(tail, schema)
    end
  end

  defp row_has_same_pk?(_, _, []) do
    true
  end

  defp row_has_same_pk?(%Masdb.Data.Row{columns: columns} = row, values, [pk | other_pks]) do
    List.first(Map.get(columns, pk)).value == Map.get(values, pk) && row_has_same_pk?(row, values, other_pks)
  end

  defp normalize_to_vals(values, [], _) do
      values
  end

  defp normalize_to_vals(values, [key | keys], timestamp) do
      Map.update!(values, key, &(%Masdb.Data.Val{since_ts: timestamp, value: &1}))
        |> normalize_to_vals(keys, timestamp)
  end
end
