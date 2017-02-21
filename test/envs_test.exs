defmodule EnvsTest do
  use PowerAssert

  import Masdb.Envs, only: [get_config: 1]

  test "defaults the save_file when needed" do
    assert Keyword.get(get_config([]), :save_file) == "./data.db"
    assert Keyword.get(get_config([save_file: "something"]), :save_file) == "something"
  end

  test "uses the join_node value or nil" do
    assert Keyword.get(get_config([join_node: "something"]), :join_node) == "something"
    assert Keyword.get(get_config([]), :join_node) == nil
  end

  test "merges the node_name and hostname" do
    # nn@hn
    # none
    assert Regex.match?(~r/generated-.*@localhost/, (Keyword.get(get_config([]), :node_name)))
    # nn
    assert Regex.match?(~r/something@localhost/,
      (Keyword.get(get_config([node_name: "something"]), :node_name))
    )
    # hn
    assert Regex.match?(~r/generated-.*@something/,
      (Keyword.get(get_config([hostname: "something"]), :node_name))
    )
    # nn@hn
    assert Regex.match?(~r/foo@bar/,
      (Keyword.get(get_config([node_name: "foo", hostname: "bar"]), :node_name))
    )
  end
end
