defmodule Masdb.Node.Supervisor do
  use Supervisor

  def start_link do
    {:ok, _} = Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    supervise([
      worker(Masdb.Node, [])
    ], strategy: :one_for_one)
  end
end
