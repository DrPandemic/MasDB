defmodule DataMapTest do
  use PowerAssert

  test "Inserting empty row must fail" do
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

    flag = Masdb.Data.Map.insert(map, inserted_schema, inserted_value)
    assert flag == :cannot_insert_empty_row
  end

  test "Inserting nonexistent row must fail" do
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

    flag = Masdb.Data.Map.insert(map, inserted_schema, inserted_value)
    assert flag == :col_doesnt_exists
  end

  test "Inserting duplicate pk in datamap must fail" do
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

    flag = Masdb.Data.Map.insert(map, inserted_schema, inserted_value)
    assert flag == :duplicate_pk
  end

  test "Inserting half duplicate pk in datamap must work" do
    c1 = %Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}
    c2 = %Masdb.Schema.Column{is_pk: true, name: "c2", type: :int}
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
                                                          "c1" => [%Masdb.Data.Val{since_ts: timestamp, value: "val1"}],
                                                          "c2" => [%Masdb.Data.Val{since_ts: timestamp, value: "val1"}]
                                                        }}}}}
    }

    {flag, _, _} = Masdb.Data.Map.insert(map, inserted_schema, inserted_value)
    assert flag == :ok
  end

  test "Inserting element with non nullable not referenced must fail" do
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

    flag = Masdb.Data.Map.insert(map, inserted_schema, inserted_value)
    assert flag == :non_nullable_not_referenced
  end

  test "Inserting element in datamap must work" do
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

    {flag, newKey, new_data_map} = Masdb.Data.Map.insert(map, inserted_schema, inserted_value)
    assert flag == :ok

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

  test "Inserting incomplete row in datamap must work" do
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

    {flag, newKey, new_data_map} = Masdb.Data.Map.insert(map, inserted_schema, inserted_value)
    assert flag == :ok

    new_table = Map.fetch!(new_data_map.map, "foo")
    new_row = Map.fetch!(new_table.rows, newKey)

    c1 = Map.fetch!(new_row.columns, "c1")
    c2 = Map.fetch(new_row.columns, "c2")
    c3 = Map.fetch!(new_row.columns, "c3")

    assert c2 == :error

    assert new_data_map.last_update_time > timestamp
    assert new_data_map.last_sync_time == timestamp

    assert c1.since_ts > timestamp
    assert c1.value == "val1"

    assert c3.since_ts == c1.since_ts
    assert c3.value == "val3"
  end

  test "Simple SELECT" do
    c1 = %Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}
    c2 = %Masdb.Schema.Column{is_pk: false, name: "c2", type: :int, nullable: true}
    c3 = %Masdb.Schema.Column{is_pk: false, name: "c3", type: :int}

    timestamp = Masdb.Timestamp.get_timestamp()
    inserted_value = %{"c1" => 1, "c2" => 2, "c3" => 3}
    inserted_schema = %Masdb.Schema{name: "foo", replication_factor: 0, columns: [c1, c2, c3]}
    inserted_nodeid = "foo@127.0.0.1"

    map = %Masdb.Data.Map{
      node_id: inserted_nodeid,
      last_update_time: timestamp,
      last_sync_time: timestamp,
      map: %{"foo" => %Masdb.Data.Table{}}
    }

    {flag, _, new_data_map} = Masdb.Data.Map.insert(map, inserted_schema, inserted_value)
    assert flag == :ok

    assert [3,2,1] == Masdb.Data.Map.select(new_data_map, "foo", ["c1", "c2", "c3"])
  end

  test "SELECT avec valeur :nil" do
    c1 = %Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}
    c2 = %Masdb.Schema.Column{is_pk: false, name: "c2", type: :int, nullable: true}
    c3 = %Masdb.Schema.Column{is_pk: false, name: "c3", type: :int}

    timestamp = Masdb.Timestamp.get_timestamp()
    inserted_value = %{"c1" => 1, "c3" => 3}
    inserted_schema = %Masdb.Schema{name: "foo", replication_factor: 0, columns: [c1, c2, c3]}
    inserted_nodeid = "foo@127.0.0.1"

    map = %Masdb.Data.Map{
      node_id: inserted_nodeid,
      last_update_time: timestamp,
      last_sync_time: timestamp,
      map: %{"foo" => %Masdb.Data.Table{}}
    }

    {flag, _, new_data_map} = Masdb.Data.Map.insert(map, inserted_schema, inserted_value)
    assert flag == :ok

    assert [3,:nil,1] == Masdb.Data.Map.select(new_data_map, "foo", ["c1", "c2", "c3"])
  end

  test "SELECT avec un schema inexistant" do
    c1 = %Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}
    c2 = %Masdb.Schema.Column{is_pk: false, name: "c2", type: :int, nullable: true}
    c3 = %Masdb.Schema.Column{is_pk: false, name: "c3", type: :int}

    timestamp = Masdb.Timestamp.get_timestamp()
    inserted_value = %{"c1" => 1, "c3" => 3}
    inserted_schema = %Masdb.Schema{name: "foo", replication_factor: 0, columns: [c1, c2, c3]}
    inserted_nodeid = "foo@127.0.0.1"

    map = %Masdb.Data.Map{
      node_id: inserted_nodeid,
      last_update_time: timestamp,
      last_sync_time: timestamp,
      map: %{"foo" => %Masdb.Data.Table{}}
    }

    {flag, _, new_data_map} = Masdb.Data.Map.insert(map, inserted_schema, inserted_value)
    assert flag == :ok

    assert :inexistent_schema == Masdb.Data.Map.select(new_data_map, "bar", ["c1", "c2", "c3"])
  end

  test "SELECT avec une colonne inexistante" do
    c1 = %Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}
    c2 = %Masdb.Schema.Column{is_pk: false, name: "c2", type: :int, nullable: true}
    c3 = %Masdb.Schema.Column{is_pk: false, name: "c3", type: :int}

    timestamp = Masdb.Timestamp.get_timestamp()
    inserted_value = %{"c1" => 1, "c2" => 2, "c3" => 3}
    inserted_schema = %Masdb.Schema{name: "foo", replication_factor: 0, columns: [c1, c2, c3]}
    inserted_nodeid = "foo@127.0.0.1"

    map = %Masdb.Data.Map{
      node_id: inserted_nodeid,
      last_update_time: timestamp,
      last_sync_time: timestamp,
      map: %{"foo" => %Masdb.Data.Table{}}
    }

    {flag, _, new_data_map} = Masdb.Data.Map.insert(map, inserted_schema, inserted_value)
    assert flag == :ok

    assert [:nil, 3, 2, 1] == Masdb.Data.Map.select(new_data_map, "foo", ["c1", "c2", "c3", "c4"])
  end
end
