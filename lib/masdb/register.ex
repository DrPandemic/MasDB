defmodule Masdb.Register.Interval do
  @type time :: Time.t
  @type opened_time :: Time.t | nil
  @type key :: integer
  @type opened_key :: key | nil

  @type t :: %Masdb.Register.Interval{
    id: Masdb.Register.id,
    first_key: key,
    last_key: opened_key,
    first_timestamp: time,
    last_timestamp: opened_time
  }
  @enfore_keys [:first_key, :last_key, :first_timestamp, :last_timestamp]
  defstruct [:id, :first_key, :last_key, :first_timestamp, :last_timestamp]
end

defmodule Masdb.Register.Table do
  @type t :: %Masdb.Register.Table{
    schema_name: String.t,
    intervals: list(Masdb.Register.Interval.t)
  }
  @enfore_keys [:schema]
  defstruct [:schema_name, intervals: []]
end

defmodule Masdb.Register.Store do
  @type t :: %Masdb.Register.Store{
    id: Masdb.Register.id,
    intervals: list(Masdb.Register.Interval.t),
    sealed: boolean
  }
  @enfore_keys [:id]
  defstruct [:id, intervals: [], sealed: false]
end

defmodule Masdb.Register do
  @type id :: integer

  @type t :: %Masdb.Register{
    stores: list(Masdb.Register.Store.t),
    schemas: list(Masdb.Schema.t),
    tables: list(Masdb.Register.Table.t)
  }
  defstruct [stores: [], schemas: [], tables: []]
end
