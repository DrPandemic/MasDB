defmodule Masdb.Data.Tuple do
  @type id :: String.t
  @type opened_id :: id | nil
  @type time :: Masdb.Timestamp.t
  @type value :: integer | float | boolean | String.t
  
  @type t :: %Masdb.Data.Tuple{
    id: id,
    timestamp: time,
    value: value,
    last_value: opened_id
  }
  @enforce_keys [:id, :timestamp, :value]
  defstruct [:id, :timestamp, :value, last_value: nil]
end