defmodule TheLeanCafe.RomanCounter do

  defp count_meta({_, %{metas: [%{last_vote: [roman_timestamp, vote]}]}}, roman_timestamp) do
    case vote do
      "+" -> 1
      "-" -> -1
      _ -> 0
    end
  end

  defp count_meta(_, _) do
    0
  end

  def value(presence_list, roman_timestamp) do
    presence_list
    |> Enum.map(&(count_meta(&1, roman_timestamp)))
    |> Enum.sum
  end

  defp count_outstanding({_, %{metas: [%{last_vote: [roman_timestamp, _vote]}]}}, roman_timestamp) do
    0
  end

  defp count_outstanding(_, _) do
    1
  end

  def outstanding(presence_list, roman_timestamp) do
    presence_list
    |> Enum.map(&(count_outstanding(&1, roman_timestamp)))
    |> Enum.sum
  end

  defp user_to_json({username, %{metas: [%{last_vote: [roman_timestamp, vote]}]}}, roman_timestamp) do
    %{username: username, last_vote: vote}
  end

  defp user_to_json({username, _}, _) do
    %{username: username, last_vote: ""}
  end

  def users_to_json(presence_list, roman_timestamp) do
    presence_list
    |> Enum.map(&(user_to_json(&1, roman_timestamp)))
  end

  defp conclusive?(value, outstanding) do
    outstanding > abs(value)
  end

  def result(presence_list, roman_timestamp) do
    vote_value = value(presence_list, roman_timestamp)
    outstanding_count = outstanding(presence_list, roman_timestamp)
    if conclusive?(vote_value, outstanding_count) do
      :inconclusive
    else
      case vote_value do
        n when n > 0 -> :+
        n when n <= 0 -> :-
      end
    end
  end

end
