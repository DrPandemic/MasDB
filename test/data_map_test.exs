defmodule DataMapTest do
  use PowerAssert
  import Masdb.Data.Map
  import Masdb.Timestamp

  test "Insert element in datamap" do
    timestamp = Masdb.Timestamp.get_timestamp()
    inserted_value = 12
    inserted_nodeid = "foo@127.0.0.1"
    inserted_table = "tableFoo"
    inserted_column = "columnBar"

    expected_id = inserted_nodeid <> inserted_table <> inserted_column <> "0"

    map = %Masdb.Data.Map{
      node_id: inserted_nodeid,
      last_update_time: timestamp,
      last_sync_time: timestamp,
      map: %{},
      next_id: 0
    }

    res = Masdb.Data.Map.put_new(map, inserted_table, inserted_column, inserted_value)
    restuple = Map.fetch!(res.map, expected_id)

    assert res.node_id == inserted_nodeid
    assert res.last_update_time > timestamp
    assert res.last_sync_time == timestamp
    assert res.next_id == 1
    
    assert restuple.id == expected_id
    assert restuple.timestamp > timestamp
    assert restuple.value == inserted_value
  end
end
