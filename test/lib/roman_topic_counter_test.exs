defmodule TheLeanCafe.RomanTopicCounterTest do

  use ExUnit.Case
  alias TheLeanCafe.RomanTopicCounter

  test "converts meta data structure to array of votes" do
    votes_structure = [%{avatar: "", last_vote: "-", username: "user1"}, %{avatar: "", last_vote: "+", username: "user2"}]
    assert RomanTopicCounter.votes_to_array(votes_structure) == ["-", "+"]
  end

  test "counts votes from votes metadata" do
    votes_list = ["+"]
    assert RomanTopicCounter.value(votes_list) == 1
  end

  test "counts downvotes" do
    votes_list = ["-"]
    assert RomanTopicCounter.value(votes_list) == -1
  end

  test "values neutral votes" do
    votes_list = ["="]
    assert RomanTopicCounter.value(votes_list) == 0
  end

  test "values mixed votes" do
    votes_list = [
      "+",
      "+",
      "=",
    ]
    assert RomanTopicCounter.value(votes_list) == 2
  end

  test "result is upvote" do
    votes_list = [
      "+",
      "+"
    ]
    assert RomanTopicCounter.result(votes_list) == :+
  end

  test "result single user" do
    votes_list = [
      "+"
    ]
    assert RomanTopicCounter.result(votes_list) == :+
  end

  test "result downvote" do
    votes_list = [
      "-",
      "-"
    ]
    assert RomanTopicCounter.result(votes_list) == :-
  end

  test "result tie" do
    votes_list = [
      "=",
      "="
    ]
    assert RomanTopicCounter.result(votes_list) == :-
  end

  test "all outstanding" do
    votes_list = [
      "",
      "",
      "",
    ]
    assert RomanTopicCounter.outstanding(votes_list) == 3
  end

  test "some outstanding" do
    votes_list = [
      "=",
      "",
      "",
    ]
    assert RomanTopicCounter.outstanding(votes_list) == 2
  end

  test "result all outstanding" do
    votes_list = [
      "",
      "",
      "",
    ]
    assert RomanTopicCounter.result(votes_list) == :inconclusive
  end

  test "result insufficient votes" do
    votes_list = [
      "+",
      "",
      "",
    ]
    assert RomanTopicCounter.result(votes_list) == :inconclusive
  end

  test "result tie with one outstanding" do
    votes_list = [
      "+",
      "",
      "-",
    ]
    assert RomanTopicCounter.result(votes_list) == :inconclusive
  end

  test "result with not enough outstanding to change outcome" do
    votes_list = [
      "+",
      "",
      "+",
    ]
    assert RomanTopicCounter.result(votes_list) == :+
  end

  test "result with enough outstanding to change outcome" do
    votes_list = [
      "+",
      "",
      "",
      "",
      "+",
    ]
    assert RomanTopicCounter.result(votes_list) == :inconclusive
  end

  test "result with enough outstanding to tie outcome" do
    votes_list = [
      "+",
      "",
      "",
      "+",
    ]
    # TODO: should this be `:inconclusive`?
    assert RomanTopicCounter.result(votes_list) == :+
  end

end
