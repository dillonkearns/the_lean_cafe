defmodule TheLeanCafe.TableChannel do
  use Phoenix.Channel

  intercept ["new_topic", "topics"]

  def join("table:" <> room_name, params, socket) do
    send(self, {:after_join, params})
    {:ok, socket}
  end

  def topic_to_html(topic) do
    dot_votes = TheLeanCafe.Topic.dot_vote_count(topic.id)
    # vote_button = "<a style='margin-right: 20px;' onclick='window.romanVote(#{topic.id});' href='javascript:void(0)')' class='btn btn-primary'>Vote</a>"
    vote_button = "<a style='margin-right: 20px; padding-left: 10px; padding-right: 10px;' onclick='window.romanVote(#{topic.id});' href='javascript:void(0)')' class='label label-info'>#{dot_votes}</a>"
    "<li>#{vote_button}#{topic.name}</li>"
  end

  def topics(table_hashid) do
    table_id = Obfuscator.decode(table_hashid)
    table =
      TheLeanCafe.Repo.get!(TheLeanCafe.Table, table_id)
      |> TheLeanCafe.Repo.preload(:topics)
    table.topics
    |> Enum.map(&topic_to_html/1)
    |> Enum.reverse
  end

  def handle_info({:after_join, _params}, socket = %{topic: "table:" <> table_hashid}) do
    push socket, "topics", %{topics: topics(table_hashid)}
    {:noreply, socket}
  end

  def handle_in("roman_vote", %{"topic_id" => topic_id}, socket = %{topic: "table:" <> table_hashid}) do
    TheLeanCafe.Repo.insert!(%TheLeanCafe.DotVote{topic_id: topic_id})
    broadcast! socket, "topics", %{topics: topics(table_hashid)}
    {:noreply, socket}
  end

  def handle_in("new_topic", %{"body" => body}, socket = %{topic: "table:" <> table_hashid}) do
    table_id = Obfuscator.decode(table_hashid)
    topic = %TheLeanCafe.Topic{table_id: table_id, name: body}
    TheLeanCafe.Repo.insert!(topic)
    broadcast! socket, "topics", %{topics: topics(table_hashid)}
    {:noreply, socket}
  end

  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end
end
