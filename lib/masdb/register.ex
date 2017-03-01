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
  @enforce_keys [:first_key, :last_key, :first_timestamp, :last_timestamp]
  defstruct [:id, :first_key, :last_key, :first_timestamp, :last_timestamp]
end

defmodule Masdb.Register.Table do
  @type t :: %Masdb.Register.Table{
    schema_name: String.t,
    intervals: list(Masdb.Register.Interval.t)
  }
  @enforce_keys [:schema]
  defstruct [:schema_name, intervals: []]
end

defmodule Masdb.Register.Store do
  @type t :: %Masdb.Register.Store{
    id: Masdb.Register.id,
    intervals: list(Masdb.Register.Interval.t),
    sealed: boolean
  }
  @enforce_keys [:id]
  defstruct [:id, intervals: [], sealed: false]
end

defmodule Masdb.Register do
  use Pipe

  @type id :: integer

  @type t :: %Masdb.Register{
    stores: list(Masdb.Register.Store.t),
    schemas: list(Masdb.Schema.t),
    tables: list(Masdb.Register.Table.t)
  }
  defstruct [stores: [], schemas: [], tables: []]

  def validate_new_schema(schemas, new_schema) do
    pipe_matching {schemas, new_schema}, :ok,
      :ok |> validate_schema |> validate_name
  end

  defp validate_schema({_, %Masdb.Schema{} = new_schema}) do
    Masdb.Schema.validate(new_schema)
  end

  defp validate_name({schemas, %Masdb.Schema{name: name}}) do
    validate_name(Enum.map(schemas, &(&1.name)), name)
  end
  defp validate_name([], _) do
    :ok
  end
  defp validate_name([name | _], new_schema_name) when name == new_schema_name do
    :duplicate_name
  end
  defp validate_name([_ | tail], new_schema_name) do
    validate_name(tail, new_schema_name)
  end
end
