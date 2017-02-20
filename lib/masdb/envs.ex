defmodule Masdb.Envs do
  @default_file "./data.db"
  @default_hostname "localhost"
  @default_name "generated"

  @doc """
  Useful env vars.
  save_file    Set the save path. Default to `./data.db`.
  node_name    Set this erlang's node's name. Is mixed with the hostname arg to generate a fully qualified name. If not
                 specified, a name will be generated.
  hostname     Set the hostname. If not specified, `localhost` will be used.
  join_node    Set the node that this node need to contact to join a cluster. It should be using the form name@hostname.

  Return keywords {:save_file, :node_name, :node_to_join}.
  """
  def get_config(config \\ Application.get_all_env(:masdb)) do
    hostname = Keyword.get(config, :hostname) || @default_hostname
    node_name = Keyword.get(config, :node_name) || generate_node_name

    [
      save_file: Keyword.get(config, :save_file) || @default_file,
      node_name: "#{node_name}@#{hostname}",
      join_node: Keyword.get(config, :join_node)
    ]
  end

  defp generate_node_name do
    hex = :erlang.monotonic_time() |>
      :erlang.phash2(2048) |>
      Integer.to_string(16)
    "#{@default_name}-#{hex}"
  end
end
