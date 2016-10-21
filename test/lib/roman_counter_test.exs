defmodule TheLeanCafe.RomanCounterTest do

  use ExUnit.Case
  alias TheLeanCafe.RomanCounter

  test "counts votes from presence metadata" do
    presence_list = %{"fred" => %{metas: [%{last_vote: [12345, "+"]}]}}
    assert RomanCounter.value(presence_list, 12345) == 1
  end

  test "skips votes that don't match timestamp" do
    presence_list = %{"fred" => %{metas: [%{last_vote: [12345, "+"]}]}}
    assert RomanCounter.value(presence_list, 12346) == 0
  end

  test "counts downvotes" do
    presence_list = %{"wilma" => %{metas: [%{last_vote: [12345, "-"]}]}}
    assert RomanCounter.value(presence_list, 12345) == -1
  end

  test "values neutral votes" do
    presence_list = %{"fred" => %{metas: [%{last_vote: [12345, "="]}]}}
    assert RomanCounter.value(presence_list, 12345) == 0
  end

  test "values mixed votes" do
    presence_list = %{
      "fred" => %{metas: [%{last_vote: [12345, "+"]}]},
      "wilma" => %{metas: [%{last_vote: [12345, "+"]}]},
      "barney" => %{metas: [%{last_vote: [12345, "="]}]},
    }
    assert RomanCounter.value(presence_list, 12345) == 2
  end

  test "users to json" do
    presence_list = %{
      "fred" => %{metas: [%{last_vote: [12345, "+"]}]},
      "wilma" => %{metas: [%{last_vote: [12345, "+"]}]},
      "barney" => %{metas: [%{last_vote: [12345, "="]}]},
      "betty" => %{metas: [%{}]},
    }
    assert RomanCounter.users_to_json(presence_list, 12345) ==
      [
        %{username: "barney", last_vote: "="},
        %{username: "betty", last_vote: ""},
        %{username: "fred", last_vote: "+"},
        %{username: "wilma", last_vote: "+"},
      ]
  end

end
