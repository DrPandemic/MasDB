defmodule Masdb.Node.Connection do
  def start(name) when is_binary(name) do
    unless Node.alive?() do
      {:ok, _} = Node.start(String.to_atom(name))
    end
  end
  def start(name) when is_nil(name) do end

  def stop do
    if Node.alive?() do
      :ok = Node.stop
    end
  end

  def list do
    Node.list
  end

  def connect(name) when is_binary(name) do
    true = Node.connect(String.to_atom(name))
  end
  def connect(name) when is_nil(name) do end
end
