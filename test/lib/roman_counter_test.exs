defmodule TheLeanCafe.RomanCounterTest do

  use ExUnit.Case
  alias TheLeanCafe.RomanCounter

  test "counts votes from presence metadata" do
    presence_list = %{"fred" => %{metas: [%{last_vote: [12345, "+"]}]}}
    assert RomanCounter.value(presence_list, last_vote: 12345) == 1
  end

  test "skips votes that don't match timestamp" do
    presence_list = %{"fred" => %{metas: [%{last_vote: [12345, "+"]}]}}
    assert RomanCounter.value(presence_list, last_vote: 12346) == 0
  end

  test "counts downvotes" do
    presence_list = %{"wilma" => %{metas: [%{last_vote: [12345, "-"]}]}}
    assert RomanCounter.value(presence_list, last_vote: 12345) == -1
  end

  test "values neutral votes" do
    presence_list = %{"fred" => %{metas: [%{last_vote: [12345, "="]}]}}
    assert RomanCounter.value(presence_list, last_vote: 12345) == 0
  end

  test "values mixed votes" do
    presence_list = %{
      "fred" => %{metas: [%{last_vote: [12345, "+"]}]},
      "wilma" => %{metas: [%{last_vote: [12345, "+"]}]},
      "barney" => %{metas: [%{last_vote: [12345, "="]}]},
    }
    assert RomanCounter.value(presence_list, last_vote: 12345) == 2
  end

  test "users to json" do
    presence_list = %{
      "fred" => %{metas: [%{last_vote: [12345, "+"]}]},
      "wilma" => %{metas: [%{last_vote: [12345, "+"]}]},
      "barney" => %{metas: [%{last_vote: [12345, "="]}]},
      "betty" => %{metas: [%{}]},
    }
    assert RomanCounter.users_to_json(presence_list, last_vote: 12345) ==
      [
        %{username: "barney", last_vote: "="},
        %{username: "betty", last_vote: ""},
        %{username: "fred", last_vote: "+"},
        %{username: "wilma", last_vote: "+"},
      ]
  end

  test "result is upvote" do
    presence_list = %{
      "fred" => %{metas: [%{last_vote: [12345, "+"]}]},
      "wilma" => %{metas: [%{last_vote: [12345, "+"]}]}
    }
    assert RomanCounter.result(presence_list, last_vote: 12345) == :+
  end

  test "result single user" do
    presence_list = %{
      "wilma" => %{metas: [%{last_vote: [12345, "+"]}]}
    }
    assert RomanCounter.result(presence_list, last_vote: 12345) == :+
  end

  test "result downvote" do
    presence_list = %{
      "fred" => %{metas: [%{last_vote: [12345, "-"]}]},
      "wilma" => %{metas: [%{last_vote: [12345, "-"]}]}
    }
    assert RomanCounter.result(presence_list, last_vote: 12345) == :-
  end

  test "result tie" do
    presence_list = %{
      "fred" => %{metas: [%{last_vote: [12345, "="]}]},
      "wilma" => %{metas: [%{last_vote: [12345, "="]}]}
    }
    assert RomanCounter.result(presence_list, last_vote: 12345) == :-
  end

  test "all outstanding" do
    presence_list = %{
      "fred" => %{metas: []},
      "wilma" => %{metas: []},
      "barney" => %{metas: []},
    }
    assert RomanCounter.outstanding(presence_list, last_vote: 12345) == 3
  end

  test "some outstanding" do
    presence_list = %{
      "fred" => %{metas: [%{last_vote: [12345, "="]}]},
      "wilma" => %{metas: []},
      "barney" => %{metas: []},
    }
    assert RomanCounter.outstanding(presence_list, last_vote: 12345) == 2
  end

  test "result all outstanding" do
    presence_list = %{
      "fred" => %{metas: []},
      "wilma" => %{metas: []},
      "barney" => %{metas: []},
    }
    assert RomanCounter.result(presence_list, last_vote: 12345) == :inconclusive
  end

  test "result insufficient votes" do
    presence_list = %{
      "fred" => %{metas: [%{last_vote: [12345, "+"]}]},
      "wilma" => %{metas: []},
      "barney" => %{metas: []},
    }
    assert RomanCounter.result(presence_list, last_vote: 12345) == :inconclusive
  end

  test "result tie with one outstanding" do
    presence_list = %{
      "fred" => %{metas: [%{last_vote: [12345, "+"]}]},
      "wilma" => %{metas: []},
      "barney" => %{metas: [%{last_vote: [12345, "-"]}]},
    }
    assert RomanCounter.result(presence_list, last_vote: 12345) == :inconclusive
  end

  test "result with not enough outstanding to change outcome" do
    presence_list = %{
      "fred" => %{metas: [%{last_vote: [12345, "+"]}]},
      "wilma" => %{metas: []},
      "barney" => %{metas: [%{last_vote: [12345, "+"]}]},
    }
    assert RomanCounter.result(presence_list, last_vote: 12345) == :+
  end

  test "result with enough outstanding to change outcome" do
    presence_list = %{
      "fred" => %{metas: [%{last_vote: [12345, "+"]}]},
      "wilma" => %{metas: []},
      "pebbles" => %{metas: []},
      "betty" => %{metas: []},
      "barney" => %{metas: [%{last_vote: [12345, "+"]}]},
    }
    assert RomanCounter.result(presence_list, last_vote: 12345) == :inconclusive
  end

  test "result with enough outstanding to tie outcome" do
    presence_list = %{
      "fred" => %{metas: [%{last_vote: [12345, "+"]}]},
      "wilma" => %{metas: []},
      "betty" => %{metas: []},
      "barney" => %{metas: [%{last_vote: [12345, "+"]}]},
    }
    # TODO: should this be `:inconclusive`?
    assert RomanCounter.result(presence_list, last_vote: 12345) == :+
  end

  describe "topic roman votes" do
    test "counts votes from presence" do
        presence_list = %{"fred" => %{metas: [%{topic_vote: [2020, "+"]}]}}
        assert RomanCounter.value(presence_list, topic_vote: 2020) == 1
    end

    test "result with enough outstanding to tie outcome" do
      presence_list = %{
        "fred" => %{metas: [%{topic_vote: [12345, "+"]}]},
        "wilma" => %{metas: []},
        "betty" => %{metas: []},
        "barney" => %{metas: [%{topic_vote: [12345, "+"]}]},
      }
      # TODO: should this be `:inconclusive`?
      assert RomanCounter.result(presence_list, topic_vote: 12345) == :+
    end
  end

end
