defmodule Masdb.Node do
  use GenServer
  alias Masdb.Node.Connection

  def start_link do
    GenServer.start_link(__MODULE__, %{node_name: nil}, name: __MODULE__)
  end

  def init(state) do
    Connection.start(Application.get_env(:masdb, :"node_name"))
    Connection.connect(Application.get_env(:masdb, :"node_to_join"))

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

  # Private
  def handle_call({:start, node_name}, _, state) do
    Connection.start(node_name)
    {:reply, :ok, %{state | node_name: node_name}}
  end

  def handle_call({:connect, node_name}, _, state) do
    Connection.connect(node_name)
    {:reply, :ok, state}
  end

  def handle_call(:list, _, state) do
    {:reply, Connection.list(), state}
  end
end
