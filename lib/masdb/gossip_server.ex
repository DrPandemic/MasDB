defmodule Masdb.Gossip.Server do
  use GenServer
  @timeout 1_000

  def start_link(name \\ __MODULE__) do
    GenServer.start_link(name, [])
  end

  def init([]) do
    schedule_work()
    {:ok, []}
  end

  def handle_info(:tick, state) do
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :tick, @timeout)
  end
end
