defmodule Masdb.Node.DistantSupervisor do
  def start_link do
    Task.Supervisor.start_link(name: Masdb.Node.DistantSupervisor)
  end

  def get_remote_pid(remote, process) do
    Task.await(
      Task.Supervisor.async({Masdb.Node.DistantSupervisor, remote},
        Masdb.Node.DistantSupervisor, :get_remote_pid_fn, [process])
    )
  end

  def get_remote_pid_fn(process) do
    Process.whereis(process)
  end
end
