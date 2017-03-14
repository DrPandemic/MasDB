defmodule Masdb.Timestamp do
  @type t :: %Masdb.Timestamp{
    time: integer,
    unique_integer: integer
  }
  @enforce_keys [:time, :unique_integer]
  defstruct [:time, :unique_integer]

  # http://erlang.org/doc/apps/erts/time_correction.html
  def get_timestamp do
    %Masdb.Timestamp{
      time: System.monotonic_time(),
      unique_integer: System.unique_integer([:monotonic])
    }
  end
end
