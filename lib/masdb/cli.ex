defmodule Masdb.CLI do
  @default_file "./data.db"
  @default_hostname "localhost"
  @default_name "generated"

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be `-h` or `--help`, which returns :help.

  It can be `start` followed by
  - `[--file=fileName|-f=fileName]` which represents where the data will be saved. Default to `./data.db`.
  - `[--name=name|-n=name]` which represents the erlang's node's name. If not specified, it will generate
     one.
  - `[--hostname=hostname]` which represents the hostname. If no specified, `localhost` whill be used. Use with the -n
     flag.
  - `[--join=name@host|-j=name@host]` which represents another MasDB node. By doing this, this node will join the other
     node's cluster.

  It can be `client --join=host:port` to open a MasDB shell on a cluster.

  Return `:help`, `{:start, filename, port, {host, port}}` or `{:client, join}`.
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv,
      switches: [help: :boolean, file: :string, name: :string, hostname: :string, join: :string],
      aliases:  [h: :help, f: :file, n: :name, j: :join]
    )

    case parse do
      {[help: true], _, _}
        -> :help
      {argv, [action], _} when is_binary(action)
        -> parse_action(argv, action)
      _ -> :help
    end
  end

  defp generate_node_name(name, hostname) do
    hex = :erlang.monotonic_time() |>
      :erlang.phash2(2048) |>
      Integer.to_string(16)
    "#{name}-#{hex}@#{hostname}"
  end

  defp parse_hostname(argv) do
    hostname = Keyword.get(argv, :hostname, @default_hostname)
    case Keyword.get(argv, :name, nil) do
      nil
        -> generate_node_name(@default_name, hostname)
      name
        -> "#{name}@#{hostname}"
    end
  end

  defp parse_action(argv, "start") do
    {
      :start,
      Keyword.get(argv, :file, @default_file),
      parse_hostname(argv),
      Keyword.get(argv, :join, nil),
    }
  end

  defp parse_action(argv, "client") do
    if Keyword.has_key?(argv, :join) do
      {:client, Keyword.get(argv, :join)}
    else
      :help
    end
  end

  defp parse_action(_, _) do
    :help
  end

  def process(:help) do
    IO.puts("""
    MasDB 0.1.0
    usage: masdb [Types] [Options]

    Types:
      -h  --help              This message
      start                   Start a new database node
      client                  Connect to an already running node and gives the user a query shell

    Start:
      -f --file=fileName      Set the save path. Default to `./data.db`
      -n --name               Set the erlang's node's name. Is mixed with the hostname to generate a fully qualified
                                name. If not specified, a name will be generated.
      --hostname              Set the hostname. If not specified, `localhost` will be used.
      -j --join=host:port     Set the an entry point to a MasDB cluster

    Client:
      -j --join=host:port     Set the an entry point to a MasDB cluster. This is a mandatory field
    """)
    System.halt(0)
  end
end
