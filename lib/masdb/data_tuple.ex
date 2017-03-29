defmodule Masdb.Data.Tuple do
  @type id :: String.t
  @type opened_id :: id | nil
  @type time :: Masdb.Timestamp.t
  @type value :: integer | float | boolean | String.t
  
  @type t :: %Masdb.Data.Tuple{
    id: id,
    since_ts: time,
    value: value,
    last_value: opened_id
  }
  @enforce_keys [:id, :since_ts, :value]
  defstruct [:id, :since_ts, :value, last_value: nil]
end