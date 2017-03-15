defmodule Masdb.Schema.Column do
  @type t :: %Masdb.Schema.Column{name: String.t, type: String.t, is_pk: boolean}
  @enforce_keys [:name, :type]
  defstruct [:name, :type, is_pk: false]
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

  def validate(%Masdb.Schema{replication_factor: f}) when f < 0 do
    :replication_factor_limits
  end

  def validate(%Masdb.Schema{}) do
    :ok
  end

  def update_timestamp(%Masdb.Schema{} = schema) do
    %{schema | creation_time: Masdb.Timestamp.get_timestamp}
  end
end
