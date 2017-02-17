defmodule Masdb.CLI do
  @default_port 1042
  @default_file "./data.db"

  def run(argv) do
    parse_args(argv)
  end

  @doc """
  `argv` can be `-h` or `--help`, which returns :help.

  It can be `start` followed by
  - `[--file=fileName|-f=fileName]` which represents where the data will be saved. Default to `./data.db`.
  - `[--port=port|-p=port]` which represents on which port the DB can be contacted. Default to 1042.
  - `[--join=host:port|-j=host:port]` which represents another MasDB node. By doing this, this node will join the other
     node's cluster.

  It can be `client --join=host:port` to open a MasDB shell on a cluster.

  Return a tuple of `{:help}`, `{:start, filename, port, {host, port}}` or `{:client, join}`.
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv,
      switches: [help: :boolean, file: :string, port: :integer, join: :string],
      aliases:  [h: :help, f: :file, p: :port, j: :join]
    )

    case parse do
      {[help: true], _, _}
        -> {:help}

      {argv, ["start"], _}
        -> parse_start(argv)

      {argv, ["client"], _}
        -> parse_client(argv)

      _ -> {:help}
    end
  end

  defp parse_join(argv) do
    host = Regex.run( ~r/(\w+):?(\d+)?/ , Keyword.get(argv, :join, ""))
    case host do
      [_, host, port] when is_binary(host) and is_binary(port)
        -> {host, elem(Integer.parse(port), 0)}
      [_, host] when is_binary(host)
        -> {host, @default_port}
        nil
        -> nil
    end
  end

  defp parse_start(argv) do
    {
      :start,
      Keyword.get(argv, :file, @default_file),
      Keyword.get(argv, :port, @default_port),
      parse_join(argv)
    }
  end

  defp parse_client(argv) do
    case parse_join(argv) do
      nil
        -> {:help}
      host
        -> {:client, host}
    end
  end
end
