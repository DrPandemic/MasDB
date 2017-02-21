defmodule Masdb.Node do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{node_name: nil}, name: __MODULE__)
  end

  def init(state) do
    {_, node_name, node_to_join} = Masdb.Envs.get_config

    Masdb.Node.Connection.start(node_name)
    Masdb.Node.Connection.connect(node_to_join)

    {:ok, state}
  end

  def start(node_name) do
    GenServer.call(__MODULE__, {:start, node_name})
  end

  def stop do
    GenServer.call(__MODULE__, :stop)
  end

  def connect(node_name) do
    GenServer.call(__MODULE__, {:connect, node_name})
  end

  def list_connected do
    GenServer.call(__MODULE__, :list_connected)
  end

  def handle_call(:list_connected, _, state) do
    {:reply, Masdb.Node.Connection.list, state}
  end

  def handle_call({:start, node_name}, _, _) do
    Masdb.Node.Connection.start(node_name)
    {:reply, :ok, %{node_name: node_name}}
  end

  def handle_call(:stop, _, _) do
    Masdb.Node.Connection.stop
    {:reply, :ok, %{node_name: nil}}
  end

  def handle_call({:connect, node_name}, _, state) do
    Masdb.Node.Connection.connect(node_name)
    {:reply, :ok, state}
  end
end
