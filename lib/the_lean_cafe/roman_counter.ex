defmodule TheLeanCafe.RomanCounter do

  def count_meta({_, %{metas: [%{last_vote: vote}]}}) do
    case vote do
      "+" -> 1
      "-" -> -1
      _ -> 0
    end
  end

  def value(presence_list) do
    presence_list
    |> Enum.map(&count_meta/1)
    |> Enum.sum
  end

  def user_to_json({username, %{metas: [%{last_vote: vote}]}}) do
    %{username: username, last_vote: vote}
  end

  def user_to_json({username, _}) do
    %{username: username, last_vote: ""}
  end

  def users_to_json(presence_list) do
    presence_list
    |> Enum.map(&user_to_json/1)
  end

end
