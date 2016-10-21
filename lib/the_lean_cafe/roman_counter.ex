defmodule TheLeanCafe.RomanCounter do

  def count_meta({_, %{metas: [%{last_vote: [roman_timestamp, vote]}]}}, roman_timestamp) do
    case vote do
      "+" -> 1
      "-" -> -1
      _ -> 0
    end
  end

  def count_meta(_, _) do
    0
  end

  def value(presence_list, roman_timestamp) do
    presence_list
    |> Enum.map(&(count_meta(&1, roman_timestamp)))
    |> Enum.sum
  end

  def user_to_json({username, %{metas: [%{last_vote: [roman_timestamp, vote]}]}}, roman_timestamp) do
    %{username: username, last_vote: vote}
  end

  def user_to_json({username, _}, _) do
    %{username: username, last_vote: ""}
  end

  def users_to_json(presence_list, roman_timestamp) do
    presence_list
    |> Enum.map(&(user_to_json(&1, roman_timestamp)))
  end

end
