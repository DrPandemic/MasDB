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
    replication_factor: integer
  }
  @enforce_keys [:name, :replication_factor]
  defstruct [:name, :replication_factor, columns: []]

  def validate(%Masdb.Schema{replication_factor: f}) when f < 0 do
    :replication_factor_limits
  end
  
  def validate(%Masdb.Schema{} = schema) do
    validate_has_pk(schema.columns)
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
end
