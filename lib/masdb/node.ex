defmodule Masdb.Node do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{node_name: nil, is_synced: false}, name: __MODULE__)
  end

  def init(state) do
    Masdb.Node.Connection.start(Application.get_env(:masdb, :"node_name"))
    Masdb.Node.Connection.connect(Application.get_env(:masdb, :"node_to_join"))

    {:ok, state}
  end

  def start(node_name) do
    GenServer.call(__MODULE__, {:start, node_name})
  end

  def connect(node_name) do
    GenServer.call(__MODULE__, {:connect, node_name})
  end

  def list do
    GenServer.call(__MODULE__, :list)
  end

  def is_synced? do
    GenServer.call(__MODULE__, :is_synced)
  end

  # Private
  def handle_call({:start, node_name}, _, state) do
    Masdb.Node.Connection.start(node_name)
    {:reply, :ok, %{state | node_name: node_name}}
  end

  def handle_call({:connect, node_name}, _, state) do
    Masdb.Node.Connection.connect(node_name)
    {:reply, :ok, state}
  end

  def handle_call(:list, _, state) do
    {:reply, Masdb.Node.Connection.list(), state}
  end

  def handle_call(:is_synced, _, state) do
    {:reply, state.is_synced, state}
  end
end
