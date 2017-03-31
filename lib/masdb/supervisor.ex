defmodule Masdb.Supervisor do
  use Supervisor

  def start_link do
    {:ok, _} = Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    supervise([
      worker(Masdb.Node, []),
      worker(Masdb.Node.DistantSupervisor, []),
      worker(Masdb.Register.Server, []),
      worker(Masdb.Gossip.Server, []),
      worker(Masdb.Initializer, [], restart: :transient),
    ], strategy: :one_for_one)
  end
end
