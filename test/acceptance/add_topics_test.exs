defmodule TheLeanCafe.AddTopicsTest do
  use TheLeanCafe.AcceptanceCase

  @tag :acceptance
  test "add topic" do
    grab_a_table

    add_topic("Some interesting topic")

    assert visible_in_element?({:css, "#topics-incomplete li"}, ~r/Some interesting topic/)
  end

  @tag :acceptance
  test "add topics and vote" do
    grab_a_table

    add_topic("Something really boring")
    add_topic("Something kind of interesting")
    add_topic("Something really interesting")

    assert visible_in_element?({:css, "#topics-incomplete li"}, ~r/Something really boring/)
  end

  def add_topic(topic_name) do
    find_element(:css, "#topic-input")
    |> click

    send_text(topic_name)

    find_element(:css, ".topic-input-form [type=submit]")
    |> click
  end

  def grab_a_table do
    navigate_to "/"
    find_element(:css, "[type=submit]")
    |> click
  end

end
