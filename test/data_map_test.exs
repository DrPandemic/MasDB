defmodule DataMapTest do
  use PowerAssert

  test "Insert empty row must fail" do
    c1 = %Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}
    c2 = %Masdb.Schema.Column{is_pk: false, name: "c2", type: :int}
    c3 = %Masdb.Schema.Column{is_pk: false, name: "c3", type: :int}

    timestamp = Masdb.Timestamp.get_timestamp()
    inserted_value = %{}
    inserted_schema = %Masdb.Schema{name: "foo", replication_factor: 0, columns: [c1, c2, c3]}
    inserted_nodeid = "foo@127.0.0.1"

    map = %Masdb.Data.Map{
      node_id: inserted_nodeid,
      last_update_time: timestamp,
      last_sync_time: timestamp,
      map: %{"foo" => %Masdb.Data.Table{}}
    }

    {_, {:cannot_insert_empty_row, _}} = Masdb.Data.Map.insert(map, inserted_schema, inserted_value)
  end

  test "Insert invalid row must fail" do
    c1 = %Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}
    c2 = %Masdb.Schema.Column{is_pk: false, name: "c2", type: :int}
    c3 = %Masdb.Schema.Column{is_pk: false, name: "c3", type: :int}

    timestamp = Masdb.Timestamp.get_timestamp()
    inserted_value = %{"c1" => "val1", "c2" => "val2", "c3" => "val3", "invalid_col" => "val"}
    inserted_schema = %Masdb.Schema{name: "foo", replication_factor: 0, columns: [c1, c2, c3]}
    inserted_nodeid = "foo@127.0.0.1"

    map = %Masdb.Data.Map{
      node_id: inserted_nodeid,
      last_update_time: timestamp,
      last_sync_time: timestamp,
      map: %{"foo" => %Masdb.Data.Table{}}
    }

    {_, {:col_doesnt_exists, _}} = Masdb.Data.Map.insert(map, inserted_schema, inserted_value)
  end

  test "Insert duplicate pk in datamap must fail" do
    c1 = %Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}
    c2 = %Masdb.Schema.Column{is_pk: false, name: "c2", type: :int}
    c3 = %Masdb.Schema.Column{is_pk: false, name: "c3", type: :int}

    timestamp = Masdb.Timestamp.get_timestamp()
    inserted_value = %{"c1" => "val1", "c2" => "val2", "c3" => "val3"}
    inserted_schema = %Masdb.Schema{name: "foo", replication_factor: 0, columns: [c1, c2, c3]}
    inserted_nodeid = "foo@127.0.0.1"

    duplicated_row_id = inserted_nodeid <> to_string(timestamp.unique_integer)

    map = %Masdb.Data.Map{
      node_id: inserted_nodeid,
      last_update_time: timestamp,
      last_sync_time: timestamp,
      map: %{"foo" => %Masdb.Data.Table {
                        rows: %{duplicated_row_id => %Masdb.Data.Row{
                                                        columns: %{
                                                          "c1" => [%Masdb.Data.Val{since_ts: timestamp, value: "val1"}]
                                                        }}}}}
    }

    {_, {:duplicate_pk, _}} = Masdb.Data.Map.insert(map, inserted_schema, inserted_value)
  end

  test "Insert element with non nullable not referenced must fail" do
    c1 = %Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}
    c2 = %Masdb.Schema.Column{is_pk: false, name: "c2", type: :int}
    c3 = %Masdb.Schema.Column{is_pk: false, name: "c3", type: :int}

    timestamp = Masdb.Timestamp.get_timestamp()
    inserted_value = %{"c2" => "val2", "c3" => "val3"}
    inserted_schema = %Masdb.Schema{name: "foo", replication_factor: 0, columns: [c1, c2, c3]}
    inserted_nodeid = "foo@127.0.0.1"

    map = %Masdb.Data.Map{
      node_id: inserted_nodeid,
      last_update_time: timestamp,
      last_sync_time: timestamp,
      map: %{"foo" => %Masdb.Data.Table{}}
    }

    {_, {:non_nullable_not_referenced, _}} = Masdb.Data.Map.insert(map, inserted_schema, inserted_value)
  end

  test "Insert element in datamap" do
    c1 = %Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}
    c2 = %Masdb.Schema.Column{is_pk: false, name: "c2", type: :int}
    c3 = %Masdb.Schema.Column{is_pk: false, name: "c3", type: :int}

    timestamp = Masdb.Timestamp.get_timestamp()
    inserted_value = %{"c1" => "val1", "c2" => "val2", "c3" => "val3"}
    inserted_schema = %Masdb.Schema{name: "foo", replication_factor: 0, columns: [c1, c2, c3]}
    inserted_nodeid = "foo@127.0.0.1"

    map = %Masdb.Data.Map{
      node_id: inserted_nodeid,
      last_update_time: timestamp,
      last_sync_time: timestamp,
      map: %{"foo" => %Masdb.Data.Table{}}
    }

    {newKey, {:ok, new_data_map}} = Masdb.Data.Map.insert(map, inserted_schema, inserted_value)
    new_table = Map.fetch!(new_data_map.map, "foo")
    new_row = Map.fetch!(new_table.rows, newKey)

    c1 = Map.fetch!(new_row.columns, "c1")
    c2 = Map.fetch!(new_row.columns, "c2")
    c3 = Map.fetch!(new_row.columns, "c3")

    assert new_data_map.last_update_time > timestamp
    assert new_data_map.last_sync_time == timestamp
    
    assert c1.since_ts > timestamp
    assert c1.value == "val1"

    assert c2.since_ts == c1.since_ts
    assert c2.value == "val2"

    assert c3.since_ts == c1.since_ts
    assert c3.value == "val3"
  end

  test "Insert incomplete row in datamap" do
    c1 = %Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}
    c2 = %Masdb.Schema.Column{is_pk: false, name: "c2", type: :int, nullable: true}
    c3 = %Masdb.Schema.Column{is_pk: false, name: "c3", type: :int}

    timestamp = Masdb.Timestamp.get_timestamp()
    inserted_value = %{"c1" => "val1", "c3" => "val3"}
    inserted_schema = %Masdb.Schema{name: "foo", replication_factor: 0, columns: [c1, c2, c3]}
    inserted_nodeid = "foo@127.0.0.1"

    map = %Masdb.Data.Map{
      node_id: inserted_nodeid,
      last_update_time: timestamp,
      last_sync_time: timestamp,
      map: %{"foo" => %Masdb.Data.Table{}}
    }

    {newKey, {:ok, new_data_map}} = Masdb.Data.Map.insert(map, inserted_schema, inserted_value)
    new_table = Map.fetch!(new_data_map.map, "foo")
    new_row = Map.fetch!(new_table.rows, newKey)

    c1 = Map.fetch!(new_row.columns, "c1")
    :error = Map.fetch(new_row.columns, "c2")
    c3 = Map.fetch!(new_row.columns, "c3")

    assert new_data_map.last_update_time > timestamp
    assert new_data_map.last_sync_time == timestamp
    
    assert c1.since_ts > timestamp
    assert c1.value == "val1"

    assert c3.since_ts == c1.since_ts
    assert c3.value == "val3"
  end
end
