defmodule ResgisterTest do
  use PowerAssert
  import Masdb.Register

  test "can work" do
    assert validate_new_schema(
      [%Masdb.Schema{name: "foo", replication_factor: 1}],
      %Masdb.Schema{name: "bar", replication_factor: 2, columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]}
    ) == :ok
  end

  test "tests name collisions" do
    assert validate_new_schema(
      [%Masdb.Schema{name: "foo", replication_factor: 1}],
      %Masdb.Schema{name: "foo", replication_factor: 2, columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]}
    ) == :duplicate_name
  end

  test "tests replication_factory limits" do
    assert validate_new_schema(
      [],
      %Masdb.Schema{name: "foo", replication_factor: -1}
    ) != :ok
  end

  test "tests that an older schema could overwrite a schema" do
    d0 = Masdb.Timestamp.get_timestamp()
    Process.sleep 1
    d1 = Masdb.Timestamp.get_timestamp()

    assert validate_new_schema(
      [%Masdb.Schema{name: "foo", replication_factor: 1, creation_time: d1, columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]}],
      %Masdb.Schema{name: "foo", replication_factor: 1, creation_time: d0, columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]}
    ) == :ok
  end

  test "merge_schemas can operate on identical schemas" do
    d0 = Masdb.Timestamp.get_timestamp()
    s0 = [%Masdb.Schema {
            name: "foo", replication_factor: 1, creation_time: d0,
            columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
          }]
    s1 = [%Masdb.Schema {
            name: "foo", replication_factor: 1, creation_time: d0,
            columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
          }]

    assert merge_schemas(s0, s1) == s0
  end

  test "merge_schemas won't take newer schemas" do
    d0 = Masdb.Timestamp.get_timestamp()
    Process.sleep 1
    d1 = Masdb.Timestamp.get_timestamp()
    s0 = [%Masdb.Schema{
            name: "foo", replication_factor: 1, creation_time: d0,
            columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
          },
          %Masdb.Schema{
            name: "bar", replication_factor: 1, creation_time: d1,
            columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
          }
         ]
    s1 = [%Masdb.Schema{
            name: "foo", replication_factor: 1, creation_time: d1,
            columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
          }]

    assert merge_schemas(s0, s1) == Masdb.Schema.sort(s0)
  end

  test "merge_schemas will take older schemas" do
    d0 = Masdb.Timestamp.get_timestamp()
    Process.sleep 1
    d1 = Masdb.Timestamp.get_timestamp()
    s0 = [%Masdb.Schema{
            name: "foo", replication_factor: 1, creation_time: d1,
            columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
          },
          %Masdb.Schema{
            name: "bar", replication_factor: 1, creation_time: d1,
            columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
          }]
    s1 = [%Masdb.Schema{
            name: "foo", replication_factor: 1, creation_time: d0,
            columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
          }]

    assert merge_schemas(s0, s1) ==
      [%Masdb.Schema{
          name: "bar", replication_factor: 1, creation_time: d1,
          columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
        },
        %Masdb.Schema{
          name: "foo", replication_factor: 1, creation_time: d0,
          columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}],
        }]
  end

  test "merge_schemas resolves same timestamp" do
    d0 = Masdb.Timestamp.get_timestamp()
    s0 = [%Masdb.Schema{
             name: "foo", replication_factor: 1, creation_time: d0,
             columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
          }]
    s1 = [%Masdb.Schema{
             name: "foo", replication_factor: 2, creation_time: d0,
             columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
          }]

    assert merge_schemas(s0, s1) == s0
    assert merge_schemas(s1, s0) == s0
  end

  test "merge_schemas will work on complexe cases" do
    d0 = Masdb.Timestamp.get_timestamp()
    Process.sleep 1
    d1 = Masdb.Timestamp.get_timestamp()
    s0 = [%Masdb.Schema{
            name: "foo", replication_factor: 1, creation_time: d1,
            columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
          },
          %Masdb.Schema{
            name: "bar", replication_factor: 1, creation_time: d0,
            columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
          },
          %Masdb.Schema{
            name: "baz", replication_factor: 1, creation_time: d0,
            columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
          },
          %Masdb.Schema{
            name: "bat", replication_factor: 1, creation_time: d1,
            columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
          }]
    s1 = [%Masdb.Schema{
            name: "foo", replication_factor: 2, creation_time: d0,
            columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
          },
          %Masdb.Schema{
             name: "bar", replication_factor: 2, creation_time: d0,
             columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
          },
          %Masdb.Schema{
            name: "baz", replication_factor: 2, creation_time: d1,
            columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
          },
          %Masdb.Schema{
            name: "mobile", replication_factor: 2, creation_time: d1,
            columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
          }]

    assert merge_schemas(s0, s1) ==
      [%Masdb.Schema{
          name: "bar", replication_factor: 1, creation_time: d0,
          columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
       },
       %Masdb.Schema{
         name: "bat", replication_factor: 1, creation_time: d1,
         columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
       },
       %Masdb.Schema{
         name: "baz", replication_factor: 1, creation_time: d0,
         columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
       },
        %Masdb.Schema{
          name: "foo", replication_factor: 2, creation_time: d0,
          columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
        },
       %Masdb.Schema{
         name: "mobile", replication_factor: 2, creation_time: d1,
         columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]
       }]
  end
end
