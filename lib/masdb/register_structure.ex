defmodule Masdb.Structure.Interval do
  @type time :: Time.t
  @type opened_time :: Time.t | nil
  @type key :: integer
  @type opened_key :: key | nil

  @type t :: %__MODULE__{
    id: Masdb.Strucutre.Resgister.id,
    first_key: key,
    last_key: opened_key,
    first_timestamp: time,
    last_timestamp: opened_time
  }
  @enforce_keys [:first_key, :last_key, :first_timestamp, :last_timestamp]
  defstruct [:id, :first_key, :last_key, :first_timestamp, :last_timestamp]
end

defmodule Masdb.Structure.Table do
  @type t :: %__MODULE__{
    schema_name: String.t,
    intervals: list(Masdb.Structure.Interval.t)
  }
  @enforce_keys [:schema]
  defstruct [:schema_name, intervals: []]
end

defmodule Masdb.Structure.Store do
  @type t :: %__MODULE__{
    id: Masdb.Structure.Register.id,
    intervals: list(Masdb.Structure.Interval.t),
    sealed: boolean
  }
  @enforce_keys [:id]
  defstruct [:id, intervals: [], sealed: false]
end

defmodule Masdb.Structure.Register do
  @type id :: integer

  @type t :: %__MODULE__{
    stores: list(Masdb.Structure.Store.t),
    schemas: list(Masdb.Schema.t),
    tables: list(Masdb.Structure.Table.t)
  }
  defstruct [stores: [], schemas: [], tables: []]
end
