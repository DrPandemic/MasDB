defmodule Masdb.Data.Val do
  @type time :: Masdb.Timestamp.t
  @type value :: integer | float | boolean | String.t | :unknown | :nil

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
  alias Masdb.Timestamp
  alias Masdb.Schema

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

  def insert(%Masdb.Data.Map{node_id: n_id, last_sync_time: l_s_t, map: old_map}, schema, values) do
    timestamp = Timestamp.get_timestamp()
    row_id = n_id <> to_string(timestamp.unique_integer)
    old_rows = Map.get(old_map, schema.name, %Masdb.Data.Table{}).rows
    pks = Schema.get_pks(schema)
    non_nullables = Schema.get_non_nullables(schema)

    with :ok <- validate_with_schema(row_id, values, schema),
         :ok <- validate_nullable_referenced(row_id, values, non_nullables),
         :ok <- validate_pk_uniqueness(row_id, values, old_rows, pks),
         {:ok, values} <- normalize_to_row(row_id, values, timestamp),
         {:ok, values} <- put_new_row(row_id, values, schema.name, n_id, l_s_t, old_map, timestamp) do
      {:ok, row_id, values}
    end
  end

  def select(%Masdb.Data.Map{map: data_map}, schema_name, columns, selector \\ :all) do
    case data_map[schema_name] do
      :nil -> :inexistent_schema
         _ -> get_rows(columns, Map.values(data_map[schema_name].rows), selector)
    end
  end

  defp validate_with_schema(row_id, values, schema) do
    keys = Map.keys(values)
    case length(keys) do
      0 -> :cannot_insert_empty_row
      _ -> validate_col_exists(keys, schema)
    end
  end

  defp validate_nullable_referenced(row_id, values, []), do: :ok
  defp validate_nullable_referenced(row_id, values, [nn_nullable | tail]) do
    case Map.get(values, nn_nullable) do
      nil -> :non_nullable_not_referenced
        _ -> validate_nullable_referenced(row_id, values, tail)
    end
  end

  defp validate_pk_uniqueness(row_id, values, rows, pks) do
    case Enum.find(Map.values(rows), &(row_has_same_pk?(&1, values, pks))) do
      nil -> :ok
        _ -> :duplicate_pk
    end
  end

  defp normalize_to_row(row_id, values, timestamp) do
    {:ok, %Masdb.Data.Row{columns: normalize_to_vals(values, Map.keys(values), timestamp)}}
  end

  defp put_new_row(row_id, row, schema_name, node_id, last_sync_time, old_map, timestamp) do
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
    values
    |> Map.update!(key, &([%Masdb.Data.Val{since_ts: timestamp, value: &1}]))
    |> normalize_to_vals(keys, timestamp)
  end

  defp get_rows(columns, data, selector, acc \\ [])
  defp get_rows(columns, [row | nexts], :all, acc) do
    get_rows(columns, nexts, :all, acc ++ flatten_cols(columns, row.columns))
  end

  defp get_rows(_, [], :all, acc) do
    acc
  end

  defp flatten_cols(columns, data, acc \\ [])
  defp flatten_cols([row | nexts], data, acc) do
    val = List.first(Map.get(data, row, [%Masdb.Data.Val{since_ts: "", value: :nil}]))
    flatten_cols(nexts, data, [val.value | acc])
  end

  defp flatten_cols([], _, acc) do
    acc
  end
end
