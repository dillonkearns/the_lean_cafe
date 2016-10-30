defmodule TheLeanCafe.AddTopicsTest do
  use TheLeanCafe.AcceptanceCase

  test "add topic" do
    grab_a_table

    add_topic("Some interesting topic")

    assert visible_in_element?({:css, "#topics-incomplete li"}, ~r/Some interesting topic/)
  end

  test "add topics and vote" do
    grab_a_table

    add_topic("Something really boring")
    add_topic("Something kind of interesting")
    add_topic("Something really interesting")

    assert topic_names == ["Something really boring", "Something kind of interesting", "Something really interesting"]

    change_state("Vote")
    vote_for_topic_at(1)
    vote_for_topic_at(2)
    vote_for_topic_at(2)

    assert topic_votes_and_names ==
      [{0, "Something really boring"}, {1, "Something kind of interesting"}, {2, "Something really interesting"}]

    change_state("Discuss!")

    assert topic_votes_and_names ==
      [{2, "Something really interesting"}, {1, "Something kind of interesting"}, {0, "Something really boring"}]
  end

  def vote_for_topic_at(index) do
    topics = find_all_elements(:css, "#topics-incomplete li")
    topics |> Enum.at(index) |> find_within_element(:css, "a") |> click
  end

  def topic_names do
    find_all_elements(:css, "#topics-incomplete li") |> Enum.map(&inner_text/1)
  end

  def change_state(link_text) do
    find_element(:link_text, link_text) |> click
  end

  def topic_votes_and_names do
    parse_int = fn(int_string) -> elem(Integer.parse(int_string), 0) end
    vote_counts = find_all_elements(:css, "#topics-incomplete li a")
    |> Enum.map(&inner_text/1)
    |> Enum.map(parse_int)

    topic_names = find_all_elements(:css, "#topics-incomplete li span") |> Enum.map(&inner_text/1)
    Enum.zip(vote_counts, topic_names)
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
