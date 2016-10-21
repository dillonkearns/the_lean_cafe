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

end
