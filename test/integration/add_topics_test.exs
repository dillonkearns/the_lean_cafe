defmodule TheLeanCafe.AddTopicsTest do
  use TheLeanCafe.AcceptanceCase

  @tag :acceptance
  test "add topic" do
    navigate_to "/"
    find_element(:css, "[type=submit]")
    |> click
  end
end
