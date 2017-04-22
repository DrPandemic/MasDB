defmodule CliTest do
  use ExUnit.Case

  import Masdb.CLI, only: [parse_args: 1]

  test "-h or --help returns :help" do
    assert parse_args(["--help"]) == :help
    assert parse_args(["-h"]) == :help
  end

  test "start parses all flags" do
    # Happy path
    assert parse_args(["start", "-f", "something", "-n", "foo", "--hostname", "bar", "-j", "bar@localhost"]) == {
      :start,
      "something",
      "foo@bar",
      "bar@localhost"
    }
    # Long names
    assert parse_args(["start", "--file", "something", "--name", "foo", "--hostname", "bar", "--join", "bar@localhost"]) == {
      :start,
      "something",
      "foo@bar",
      "bar@localhost"
    }

    # No -f, uses default file
    assert parse_args(["start", "-n", "foo", "--hostname", "bar", "-j", "bar@localhost"]) == {
      :start,
      "./data.db",
      "foo@bar",
      "bar@localhost"
    }

    # No joins
    assert parse_args(["start", "-f", "something", "-n", "foo"]) == {
      :start,
      "something",
      "foo@localhost",
      nil
    }

    # No --hostname, uses localhost
    assert parse_args(["start", "-f", "something", "-n", "foo"]) == {
      :start,
      "something",
      "foo@localhost",
      nil
    }

    # Generates a name if no -n
    assert is_binary(elem(parse_args(["start", "--hostname", "bar"]), 2))
    assert Regex.match?(~r/.*@bar/, elem(parse_args(["start", "--hostname", "bar"]), 2))

    # Generates a name if no -n no --hostname
    assert is_binary(elem(parse_args(["start"]), 2))
    assert Regex.match?(~r/.*@localhost/, elem(parse_args(["start"]), 2))

    assert parse_args(["something"]) == :help
  end

  test "client parses all flags" do
    assert parse_args(["client", "-j", "foo@localhost"]) == {
      :client,
      "foo@localhost"
    }
    assert parse_args(["client", "--join", "foo@localhost"]) == {
      :client,
      "foo@localhost"
    }

    assert parse_args(["client"]) == :help
  end
end
