defmodule Masdb.Node.Communication do
  def select_quorum(nodes) do
    Enum.take_random(nodes, Integer.floor_div(length(nodes), 2) + 1)
  end
end
