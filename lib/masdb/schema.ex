defmodule Masdb.Schema.Column do
  @type t :: %Masdb.Schema.Column{name: String.t, type: String.t, is_pk: boolean}
  @enfore_keys [:name, :type]
  defstruct [:name, :type, is_pk: false]
end

defmodule Masdb.Schema do
  # A replication_factor of 0 is considered as `everywhere`
  @type t :: %Masdb.Schema{
    name: String.t,
    columns: list(Masdb.Schema.Column.t),
    replication_factor: integer
  }
  @enfore_keys [:name, :columns, :replication_factor]
  defstruct [:name, :columns, :replication_factor]
end
