defmodule Masdb.Data.Map do
  @type node_id :: String.t
  @type time :: Masdb.Timestamp.t
  @type opened_time :: time | nil
  @type data_map :: %{String.t => Masdb.Data.Tuple.t}

  @type t :: %Masdb.Data.Map{
    node_id: node_id,
    last_update_time: time,
    last_sync_time: opened_time,
    map: data_map,
    next_id: integer
  }
  @enforce_keys [:node_id, :last_update_time]
  defstruct [:node_id, :last_update_time, last_sync_time: nil, map: %{}, next_id: 0]

  def put_new(map, schema, column, value) do
    timestamp = Masdb.Timestamp.get_timestamp()

    %Masdb.Data.Map{
      node_id: map.node_id,
      last_update_time: timestamp,
      last_sync_time: map.last_sync_time,
      map: insert_into_map(map, schema, column, value, timestamp),
      next_id: map.next_id + 1
    }
  end

  defp insert_into_map(map, schema, column, value, timestamp) do
    Map.put_new(map, get_id(map, schema, column), %Masdb.Data.Tuple{
                                                    id: get_id(map, schema, column),
                                                    since_ts: timestamp,
                                                    value: value
                                                  })
  end

  defp get_id(map, schema, column) do
    map.node_id <> schema <> column <> to_string(map.next_id)
  end
end