defmodule TheLeanCafe.RomanTopicCounterTest do

  use ExUnit.Case
  alias TheLeanCafe.RomanTopicCounter

  test "counts votes from presence metadata" do
    presence_list = %{"fred" => "+"}
    assert RomanTopicCounter.value(presence_list) == 1
  end

  test "counts downvotes" do
    presence_list = %{"wilma" => "-"}
    assert RomanTopicCounter.value(presence_list) == -1
  end

  test "values neutral votes" do
    presence_list = %{"fred" => "="}
    assert RomanTopicCounter.value(presence_list) == 0
  end

  test "values mixed votes" do
    presence_list = %{
      "fred" => "+",
      "wilma" => "+",
      "barney" => "=",
    }
    assert RomanTopicCounter.value(presence_list) == 2
  end

  test "result is upvote" do
    presence_list = %{
      "fred" => "+",
      "wilma" => "+"
    }
    assert RomanTopicCounter.result(presence_list) == :+
  end

  test "result single user" do
    presence_list = %{
      "wilma" => "+"
    }
    assert RomanTopicCounter.result(presence_list) == :+
  end

  test "result downvote" do
    presence_list = %{
      "fred" => "-",
      "wilma" => "-"
    }
    assert RomanTopicCounter.result(presence_list) == :-
  end

  test "result tie" do
    presence_list = %{
      "fred" => "=",
      "wilma" => "="
    }
    assert RomanTopicCounter.result(presence_list) == :-
  end

  test "all outstanding" do
    presence_list = %{
      "fred" => "",
      "wilma" => "",
      "barney" => "",
    }
    assert RomanTopicCounter.outstanding(presence_list) == 3
  end

  test "some outstanding" do
    presence_list = %{
      "fred" => "=",
      "wilma" => "",
      "barney" => "",
    }
    assert RomanTopicCounter.outstanding(presence_list) == 2
  end

  test "result all outstanding" do
    presence_list = %{
      "fred" => "",
      "wilma" => "",
      "barney" => "",
    }
    assert RomanTopicCounter.result(presence_list) == :inconclusive
  end

  test "result insufficient votes" do
    presence_list = %{
      "fred" => "+",
      "wilma" => "",
      "barney" => "",
    }
    assert RomanTopicCounter.result(presence_list) == :inconclusive
  end

  test "result tie with one outstanding" do
    presence_list = %{
      "fred" => "+",
      "wilma" => "",
      "barney" => "-",
    }
    assert RomanTopicCounter.result(presence_list) == :inconclusive
  end

  test "result with not enough outstanding to change outcome" do
    presence_list = %{
      "fred" => "+",
      "wilma" => "",
      "barney" => "+",
    }
    assert RomanTopicCounter.result(presence_list) == :+
  end

  test "result with enough outstanding to change outcome" do
    presence_list = %{
      "fred" => "+",
      "wilma" => "",
      "pebbles" => "",
      "betty" => "",
      "barney" => "+",
    }
    assert RomanTopicCounter.result(presence_list) == :inconclusive
  end

  test "result with enough outstanding to tie outcome" do
    presence_list = %{
      "fred" => "+",
      "wilma" => "",
      "betty" => "",
      "barney" => "+",
    }
    # TODO: should this be `:inconclusive`?
    assert RomanTopicCounter.result(presence_list) == :+
  end

end
