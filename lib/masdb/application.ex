defmodule Masdb.Application do
  use Application

  def start(_, _) do
    Port.open({:spawn, "epmd"}, [])

    {:ok, _} = Masdb.Node.Supervisor.start_link
  end
end
