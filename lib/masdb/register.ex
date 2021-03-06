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
  alias Masdb.Schema

  @type id :: integer

  @type t :: %Masdb.Register{
    stores: list(Masdb.Register.Store.t),
    schemas: list(Masdb.Schema.t),
    tables: list(Masdb.Register.Table.t),
    synced: boolean
  }
  defstruct [stores: [], schemas: [], tables: [], synced: false]

  def merge_schemas(olds, news) do
    olds ++ news
    |> Enum.group_by(fn s -> s.name end)
    |> Enum.to_list
    |> choose_schemas([])
  end
  defp choose_schemas([], acc), do: Schema.sort(acc)
  defp choose_schemas([{_, schemas}|tail], acc) do
    schema = Enum.min_by(schemas, fn s -> {s.creation_time, s} end)
    choose_schemas(tail, [schema | acc])
  end

  def validate_new_schema(schemas, new_schema) do
    with :ok <- validate_schema(schemas, new_schema) do
      validate_name_or_age(schemas, new_schema)
    end
  end

  defp validate_schema(_, %Masdb.Schema{} = new_schema) do
    Schema.validate(new_schema)
  end

  defp validate_name_or_age(schemas, %Masdb.Schema{name: name} = schema) do
    case validate_name(Enum.map(schemas, &(&1.name)), name) do
      :ok -> :ok
      error ->
        case validate_age(schemas, schema) do
          :ok -> :ok
          _ -> error
        end
    end
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

  defp validate_age(schemas, schema) do
    case Enum.find(schemas, fn s -> s.name == schema.name end) do
      nil -> :notfound
      s ->
        if s.creation_time > schema.creation_time do
          :ok
        else
          :newer
        end
    end
  end
end
