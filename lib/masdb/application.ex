defmodule Masdb.Application do
  use Application

  def start(_, _) do
    {:ok, _} = Masdb.Node.Supervisor.start_link
  end
end
