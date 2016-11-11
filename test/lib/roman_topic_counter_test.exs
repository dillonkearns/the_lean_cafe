defmodule TheLeanCafe.RomanTopicCounterTest do

  use ExUnit.Case
  alias TheLeanCafe.RomanTopicCounter

  test "converts meta data structure to array of votes" do
    votes_structure = [%{avatar: "", last_vote: "-", username: "user1"}, %{avatar: "", last_vote: "+", username: "user2"}]
    assert RomanTopicCounter.votes_to_array(votes_structure) == ["-", "+"]
  end

  test "counts votes from votes metadata" do
    assert RomanTopicCounter.value(["+"]) == 1
  end

  test "counts downvotes" do
    assert RomanTopicCounter.value(["-"]) == -1
  end

  test "values neutral votes" do
    assert RomanTopicCounter.value(["="]) == 0
  end

  test "values mixed votes" do
    assert RomanTopicCounter.value(["+", "+", "="]) == 2
  end

  test "result is upvote" do
    assert RomanTopicCounter.result(["+", "+"]) == :+
  end

  test "result single user" do
    assert RomanTopicCounter.result(["+"]) == :+
  end

  test "result downvote" do
    assert RomanTopicCounter.result(["-", "-"]) == :-
  end

  test "result tie" do
    assert RomanTopicCounter.result(["=", "="]) == :-
  end

  test "all outstanding" do
    assert RomanTopicCounter.outstanding(["", "", "",]) == 3
  end

  test "some outstanding" do
    assert RomanTopicCounter.outstanding(["=", "", "",]) == 2
  end

  test "result all outstanding" do
    assert RomanTopicCounter.result(["", "", "",]) == :inconclusive
  end

  test "result insufficient votes" do
    assert RomanTopicCounter.result(["+", "", "",]) == :inconclusive
  end

  test "result tie with one outstanding" do
    assert RomanTopicCounter.result(["+", "", "-",]) == :inconclusive
  end

  test "result with not enough outstanding to change outcome" do
    assert RomanTopicCounter.result(["+", "", "+",]) == :+
  end

  test "result with enough outstanding to change outcome" do
    assert RomanTopicCounter.result(["+", "", "", "", "+",]) == :inconclusive
  end

  test "result with enough outstanding to tie outcome" do
    # TODO: should this be `:inconclusive`?
    assert RomanTopicCounter.result(["+", "", "", "+",]) == :+
  end

end
