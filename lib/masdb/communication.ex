defmodule Masdb.Node.Communication do
  def select_quorum(nodes, size \\ nil) do
    Enum.take_random(nodes, size || quorum_size(length(nodes)))
  end

  def select_with_rest(nodes, size) do
    selected = select_quorum(nodes, size)
    {selected, remove_all(nodes, selected)}
  end

  defp remove_all(nodes, selected) do
    Enum.reject(nodes, fn n ->
      Enum.find(selected, &(&1 == n))
    end)
  end

  def quorum_size(0), do: 0
  def quorum_size(size) do
    Integer.floor_div(size, 2) + 1
  end

  def has_quorum?([], []), do: true
  def has_quorum?(_, []), do: false
  def has_quorum?(nodes, answers) when length(nodes) < length(answers), do: false
  def has_quorum?(nodes, answers) do
    answers
    |> Enum.reduce(0, fn (a, acc) -> if elem(a, 1) == :ok, do: acc + 1, else: acc end)
    >= quorum_size(length(nodes))
  end
end
