defmodule Masdb.Gossip.Server do
  use GenServer
  alias Masdb.Node.DistantSupervisor
  alias Masdb.Register

  def received_gossip(gossip) do
    Register.Server.received_gossip(gossip)
  end

  def start_link(name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def init([]) do
    schedule_work()
    {:ok, []}
  end

  def handle_info(:tick, state) do
    perform_gossip()
    schedule_work()
    {:noreply, state}
  end

  defp perform_gossip do
    if Masdb.Register.Server.is_synced? do
      DistantSupervisor.query_remote_nodes(
        Enum.take_random(Masdb.Node.list(), Application.get_env(:masdb, :"gossip_size")),
        Masdb.Gossip.Server,
        :received_gossip,
        [Masdb.Register.Server.get_state()]
      )
    end
  end

  defp schedule_work do
    Process.send_after(self(), :tick, Application.get_env(:masdb, :"gossip_interval"))
  end
end
