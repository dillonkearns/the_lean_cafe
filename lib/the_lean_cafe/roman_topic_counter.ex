defmodule TheLeanCafe.RomanTopicCounter do

  def result(votes) do
    vote_value = value(votes)
    if conclusive?(vote_value, outstanding_count(votes)) do
      :inconclusive
    else
      conclusive_result(vote_value)
    end
  end

  def value(votes) do
    votes
    |> Enum.map(&(string_to_value(&1)))
    |> Enum.sum
  end

  def outstanding_count(votes) do
    votes
    |> Enum.filter(fn(vote) -> vote == "" end)
    |> Enum.count
  end

  def votes_to_array(votes_structure) do
    votes_structure
    |> Enum.map(&(&1.last_vote))
  end

  defp conclusive_result(vote_value) when vote_value > 0, do: :+
  defp conclusive_result(vote_value) when vote_value <= 0, do: :-

  defp conclusive?(vote_value, outstanding) do
    outstanding > abs(vote_value)
  end

  defp string_to_value(vote) do
    case vote do
      "+" -> 1
      "-" -> -1
      "" -> 0
      "=" -> 0
    end
  end

end
