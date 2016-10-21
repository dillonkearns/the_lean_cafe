defmodule TheLeanCafe.TableChannel do
  use Phoenix.Channel
  alias TheLeanCafe.Presence

  intercept ["new_topic", "topics", "close_poll"]

  def join("table:" <> _room_name, params, socket) do
    IO.puts "username = #{socket.assigns.username}"
    send(self, {:after_join, params})
    {:ok, socket}
  end

  def topics(table_hashid) do
    table_id = Obfuscator.decode(table_hashid)
    table = TheLeanCafe.Repo.get!(TheLeanCafe.Table, table_id)
    topics_and_dot_votes =
      if table.poll_closed do
        TheLeanCafe.Topic.sorted_with_vote_counts(table_id)
      else
        TheLeanCafe.Topic.with_vote_counts(table_id)
      end

    Phoenix.View.render_to_string(TheLeanCafe.TopicView, "index.html", topics_and_dot_votes: topics_and_dot_votes)
  end

  def track_new_user(socket) do
    Presence.track(socket, socket.assigns.username, %{
      joined_at: :os.system_time(:milli_seconds)
    })
    broadcast_users(socket)
  end

  def count_vote(socket, vote) do
    Presence.update(socket, socket.assigns.username, %{last_vote: vote})
    broadcast_users(socket)
  end

  def connected_users(socket) do
    socket
    |> Presence.list
    |> TheLeanCafe.RomanCounter.users_to_json
  end

  def broadcast_users(socket) do
    broadcast! socket, "users", %{users: connected_users(socket)}
  end

  def handle_info({:after_join, _params}, socket = %{topic: "table:" <> table_hashid}) do
    track_new_user(socket)
    push socket, "topics", topics_payload(table_hashid)
    {:noreply, socket}
  end

  def handle_in("roman_vote", %{"topic_id" => topic_id}, socket = %{topic: "table:" <> table_hashid}) do
    TheLeanCafe.Repo.insert!(%TheLeanCafe.DotVote{topic_id: topic_id})
    broadcast! socket, "topics", %{topics: topics(table_hashid)}
    {:noreply, socket}
  end

  def handle_in("close_poll", _, socket = %{topic: "table:" <> table_hashid}) do
    table_id = Obfuscator.decode(table_hashid)
    table = TheLeanCafe.Repo.get!(TheLeanCafe.Table, table_id)
    change = Ecto.Changeset.change(table, poll_closed: true)
    TheLeanCafe.Repo.update(change)
    broadcast! socket, "topics", topics_payload(table_hashid)
    {:noreply, socket}
  end

  def topics_payload(table_hashid) do
    table_id = Obfuscator.decode(table_hashid)
    table = TheLeanCafe.Repo.get!(TheLeanCafe.Table, table_id)
    %{topics: topics(table_hashid), pollClosed: table.poll_closed}
  end

  def handle_in("new_topic", %{"body" => body}, socket = %{topic: "table:" <> table_hashid}) do
    table_id = Obfuscator.decode(table_hashid)
    topic = %TheLeanCafe.Topic{table_id: table_id, name: body}
    TheLeanCafe.Repo.insert!(topic)
    broadcast! socket, "topics", topics_payload(table_hashid)
    {:reply, :ok, socket}
  end

  def handle_in("vote", %{"vote" => vote}, socket = %{assigns: %{username: username}, topic: "table:" <> table_hashid}) do
    count_vote(socket, vote)
    {:reply, :ok, socket}
  end

  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end
end
