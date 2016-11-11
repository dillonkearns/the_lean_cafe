defmodule TheLeanCafe.RomanTopicCounter do

  def result(vote_map) do
    vote_value = value(vote_map)
    outstanding_count = outstanding(vote_map)
    if conclusive?(vote_value, outstanding_count) do
      :inconclusive
    else
      case vote_value do
        n when n > 0 -> :+
        n when n <= 0 -> :-
      end
    end
  end

  def value(vote_map) do
    vote_map
    |> Enum.map(&(string_to_value(&1)))
    |> Enum.sum
  end

  defp conclusive?(value, outstanding) do
    outstanding > abs(value)
  end

  def outstanding(vote_map) do
    vote_map
    |> Enum.filter(fn(vote) -> vote == "" end)
    |> Enum.count
  end

  def votes_to_array(votes_structure) do
    votes_structure
    |> Enum.map(&(&1.last_vote))
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
