defmodule Masdb.Gossip.Server do
  use GenServer

  def received_gossip(gossip) do
    Masdb.Register.Server.received_gossip(gossip)
  end

  def start_link(name \\ __MODULE__) do
    GenServer.start_link(name, [])
  end

  def init([]) do
    schedule_work()
    {:ok, []}
  end

  def handle_info(:tick, state) do
    gossip()
    schedule_work()
    {:noreply, state}
  end

  defp gossip do
    if Masdb.Node.is_synced? do
      Masdb.Node.DistantSupervisor.query_remote_node(
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
