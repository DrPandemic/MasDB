defmodule InitializerTest do
  use PowerAssert
  import Masdb.Initializer

  test "merge_answers can work with only one answer" do
    answers = ["foo@localhost": [%Masdb.Schema{name: "foo", replication_factor: 2, columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]}]]

    [%Masdb.Schema{name: name}] = merge_answers(answers)
    assert name == "foo"
  end

  test "merge_answers can work on empty answer" do
    answers = ["foo@localhost": []]

    assert merge_answers(answers) == []
  end

  test "merge_answers can work with multiple answers" do
    answers = [
      "foo@localhost": [%Masdb.Schema{name: "foo", replication_factor: 2, columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]}],
      "bar@something": [%Masdb.Schema{name: "bar", replication_factor: 2, columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]}],
      "bar@something": [%Masdb.Schema{name: "bar", replication_factor: 2, columns: [%Masdb.Schema.Column{is_pk: true,  name: "c1", type: :int}]}]
    ]

    result = answers
    |> merge_answers
    |> Enum.map(&(&1.name))
    |> Enum.sort

    assert result == ["bar", "foo"]
  end
end
