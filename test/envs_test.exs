defmodule EnvsTest do
  use PowerAssert

  import Masdb.Envs, only: [get_config: 1]

  test "defaults the save_file when needed" do
    assert elem(get_config([]), 0) == "./data.db"
    assert elem(get_config([save_file: "something"]), 0) == "something"
  end

  test "uses the node_to_join value or nil" do
    assert elem(get_config([node_to_join: "something"]), 2) == "something"
    assert elem(get_config([]), 2) == nil
  end

  test "merges the node_name and hostname" do
    # nn@hn
    # none
    assert Regex.match?(~r/generated-.*@localhost/, (elem(get_config([]), 1)))
    # nn
    assert Regex.match?(~r/something@localhost/,
      (elem(get_config([node_name: "something"]), 1))
    )
    # hn
    assert Regex.match?(~r/generated-.*@something/,
      (elem(get_config([hostname: "something"]), 1))
    )
    # nn@hn
    assert Regex.match?(~r/foo@bar/,
      (elem(get_config([node_name: "foo", hostname: "bar"]), 1))
    )
  end
end
