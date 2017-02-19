defmodule Masdb.Node do
  def start(name) do
    unless Node.alive?() do
      {:ok, _} = Node.start(name)
    end
  end

  def connect(name) do
    true = Node.connect(name)
  end
end
