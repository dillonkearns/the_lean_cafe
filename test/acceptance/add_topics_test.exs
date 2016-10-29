defmodule TheLeanCafe.AddTopicsTest do
  use TheLeanCafe.AcceptanceCase

  @tag :acceptance
  test "add topic" do
    navigate_to "/"
    find_element(:css, "[type=submit]")
    |> click

    find_element(:css, "#topic-input")
    |> click

    send_text("Some interesting topic")

    find_element(:css, ".topic-input-form [type=submit]")
    |> click

    assert visible_in_element?({:css, "#topics-incomplete li"}, ~r/Some interesting topic/)
  end

end
