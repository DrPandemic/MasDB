defmodule Masdb.Gossip.Supervisor do
  def start_link do
    Task.Supervisor.start_link(name: __MODULE__)
  end

  def spawn_task(fun) do
    Task.Supervisor.async_nolink(__MODULE__, fun)
  end
end
