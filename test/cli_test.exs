defmodule CliTest do
  use ExUnit.Case

  import Masdb.CLI, only: [parse_args: 1]

  test "-h or --help returns :help" do
    assert parse_args(["-h"]) == {:help}
    assert parse_args(["--help"]) == {:help}
  end

  test "start parses all flags" do
    assert parse_args(["start", "-f", "something", "-p", "1337", "-j", "localhost:1338"]) == {
      :start,
      "something",
      1337,
      {"localhost", 1338}
    }
    assert parse_args(["start", "--file", "something", "--port", "1337", "--join", "localhost:1338"]) == {
      :start,
      "something",
      1337,
      {"localhost", 1338}
    }

    assert parse_args(["start", "-p", "1337", "-j", "localhost:1338"]) == {
      :start,
      "./data.db",
      1337,
      {"localhost", 1338}
    }

    assert parse_args(["start", "-f", "something", "-j", "localhost:1338"]) == {
      :start,
      "something",
      1042,
      {"localhost", 1338}
    }

    assert parse_args(["start", "-f", "something", "-p", "1337"]) == {
      :start,
      "something",
      1337,
      nil
    }
    assert parse_args(["start", "-f", "something", "-p", "1337", "-j", "localhost"]) == {
      :start,
      "something",
      1337,
      {"localhost", 1042}
    }

    assert parse_args(["something"]) == {:help}
  end

  test "client parses all flags" do
    assert parse_args(["client", "-j", "localhost:1338"]) == {
      :client,
      {"localhost", 1338}
    }
    assert parse_args(["client", "--join", "localhost:1338"]) == {
      :client,
      {"localhost", 1338}
    }

    assert parse_args(["client", "-j", "localhost"]) == {
      :client,
      {"localhost", 1042}
    }

    assert parse_args(["client"]) == {
      :help,
    }
  end
end
