defmodule Masdb.Schema.Column do
  @type t :: %Masdb.Schema.Column{name: String.t, type: String.t, is_pk: boolean}
  @enfore_keys [:name, :type]
  defstruct [:name, :type, is_pk: false]
end

defmodule Masdb.Schema do
  @type t :: %Masdb.Schema{name: String.t, columns: list(Masdb.Schema.Column)}
  @enfore_keys [:name, :columns]
  defstruct [:name, :columns]
end
