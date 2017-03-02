defmodule Masdb.Time do
  # http://erlang.org/doc/apps/erts/time_correction.html
  def get_timestamp do
    {
      System.monotonic_time(),
      System.unique_integer([:monotonic])
    }
  end
end
