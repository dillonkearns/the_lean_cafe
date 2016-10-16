defmodule TheLeanCafe.TopicViewTest do
  use TheLeanCafe.ConnCase, async: true

  import Phoenix.View

  test "renders single topic html" do
    topic = %TheLeanCafe.Topic{name: "Some cool topic"}
    assert render_to_string(TheLeanCafe.TopicView, "show.html", topic: topic, dot_votes: 0) =~
       ~r(<li>.*Some cool topic</li>)s
  end

  test "shows vote button next to topic" do
    topic = %TheLeanCafe.Topic{id: 123, name: "Some cool topic"}
    assert render_to_string(TheLeanCafe.TopicView, "show.html", topic: topic, dot_votes: 0) =~
       ~r/<a.*onclick="window.romanVote\(123\);".*<\/a>/s
  end

  test "shows correct vote count" do
    topic = %TheLeanCafe.Topic{id: 123, name: "Some cool topic"}
    assert render_to_string(TheLeanCafe.TopicView, "show.html", topic: topic, dot_votes: 456) =~
       ~r/456/s
  end

end
