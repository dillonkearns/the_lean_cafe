defmodule TheLeanCafe.TopicViewTest do
  use TheLeanCafe.ConnCase, async: true
  alias TheLeanCafe.{TopicView, Topic}
  import Phoenix.View

  test "renders single topic html" do
    topic = %Topic{name: "Some cool topic"}
    assert render_to_string(TopicView, "show.html", topic: topic, dot_votes: 0) =~
       ~r(<li>.*Some cool topic</li>)s
  end

  test "shows vote button next to topic" do
    topic = %Topic{id: 123, name: "Some cool topic"}
    assert render_to_string(TopicView, "show.html", topic: topic, dot_votes: 0) =~
       ~r/<a.*onclick="window.dotVote\(123\);".*<\/a>/s
  end

  test "shows correct vote count" do
    topic = %Topic{id: 123, name: "Some cool topic"}
    assert render_to_string(TopicView, "show.html", topic: topic, dot_votes: 456) =~
       ~r/456/s
  end

  test "renders list of topics within table" do
    topic1 = %Topic{id: 123, name: "Some cool topic"}
    topic2 = %Topic{id: 124, name: "Another topic"}
    topics_and_dot_votes = [{topic1, 10}, {topic2, 6}]
    assert render_to_string(TopicView, "index.html", topics_and_dot_votes: topics_and_dot_votes) =~
       ~r/10.*Some cool topic.*6.*Another topic/s
  end

end
