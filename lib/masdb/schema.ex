defmodule Masdb.Schema.Column do
  @type t :: %Masdb.Schema.Column{name: String.t, type: String.t, is_pk: boolean, nullable: boolean}
  @enforce_keys [:name, :type]
  defstruct [:name, :type, is_pk: false, nullable: false]
end

defmodule Masdb.Schema do
  # A replication_factor of 0 is considered as `everywhere`
  @type t :: %Masdb.Schema{
    name: String.t,
    columns: list(Masdb.Schema.Column.t),
    replication_factor: integer,
    creation_time: Masdb.Timestamp.t
  }
  @enforce_keys [:name, :replication_factor]
  defstruct [:name, :replication_factor, columns: [], creation_time: Masdb.Timestamp.get_timestamp()]

  def get_pk(%Masdb.Schema{columns: cols}) do
    Enum.filter_map(cols, fn(c) -> c.is_pk end, &(&1.name))
  end

  def get_non_nullables(%Masdb.Schema{columns: cols}) do
    Enum.filter_map(cols, fn(c) -> c.nullable == false end, &(&1.name))
  end

  def update_timestamp(%Masdb.Schema{} = schema) do
    %Masdb.Schema{schema | creation_time: Masdb.Timestamp.get_timestamp}
  end

  def validate(%Masdb.Schema{replication_factor: f}) when f < 0 do
    :replication_factor_limits
  end

  def validate(%Masdb.Schema{} = schema) do
    validate_has_pk(schema.columns)
  end

  defp validate_has_pk([%Masdb.Schema.Column{is_pk: true, nullable: true} | _]) do
    :pk_cannot_be_nullable
  end

  defp validate_has_pk([%Masdb.Schema.Column{is_pk: true} | _]) do
    :ok
  end

  defp validate_has_pk([%Masdb.Schema.Column{is_pk: false} | tail]) do
    validate_has_pk(tail)
  end

  defp validate_has_pk([]) do
    :primary_key_is_needed
  end

  def sort(schemas) do
    Enum.sort_by(schemas, fn s -> s.name end)
  end
end
