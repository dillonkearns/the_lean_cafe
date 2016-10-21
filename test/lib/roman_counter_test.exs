defmodule TheLeanCafe.RomanCounterTest do

  use ExUnit.Case

  test "counts votes from presence metadata" do
    presence_list = %{"fred" => %{metas: [%{last_vote: "+"}]}}
    assert TheLeanCafe.RomanCounter.value(presence_list) == 1
  end

  test "counts downvotes" do
    presence_list = %{"wilma" => %{metas: [%{last_vote: "-"}]}}
    assert TheLeanCafe.RomanCounter.value(presence_list) == -1
  end

  test "values neutral votes" do
    presence_list = %{"fred" => %{metas: [%{last_vote: "="}]}}
    assert TheLeanCafe.RomanCounter.value(presence_list) == 0
  end

  test "values mixed votes" do
    presence_list = %{
      "fred" => %{metas: [%{last_vote: "+"}]},
      "wilma" => %{metas: [%{last_vote: "+"}]},
      "barney" => %{metas: [%{last_vote: "="}]},
    }
    assert TheLeanCafe.RomanCounter.value(presence_list) == 2
  end

  test "users to json" do
    presence_list = %{
      "fred" => %{metas: [%{last_vote: "+"}]},
      "wilma" => %{metas: [%{last_vote: "+"}]},
      "barney" => %{metas: [%{last_vote: "="}]},
      "betty" => %{metas: [%{}]},
    }
    assert TheLeanCafe.RomanCounter.users_to_json(presence_list) ==
      [
        %{username: "barney", last_vote: "="},
        %{username: "betty", last_vote: ""},
        %{username: "fred", last_vote: "+"},
        %{username: "wilma", last_vote: "+"},
      ]
  end

end
