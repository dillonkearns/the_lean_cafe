defmodule TheLeanCafe.TableChannel do
  use Phoenix.Channel
  alias TheLeanCafe.{Presence, Table, Topic, DotVote, Repo, TopicView, RomanCounter}

  intercept ["new_topic", "topics", "close_poll"]

  def join("table:" <> _room_name, params, socket) do
    send(self, {:after_join, params})
    {:ok, socket}
  end

  def topics(table_hashid) do
    table_id = Obfuscator.decode(table_hashid)
    table = Repo.get!(Table, table_id)

    topics_and_dot_votes =
      table
      |> Table.topics_query
      |> Topic.with_vote_counts
      |> Repo.all

    Phoenix.View.render_to_string(TopicView, "index.html", topics_and_dot_votes: topics_and_dot_votes)
  end

  def track_new_user(socket) do
    Presence.track(socket, socket.assigns.username, %{
      joined_at: :os.system_time(:milli_seconds)
    })
    broadcast_users(socket)
  end

  def clear_votes(socket = %{topic: "table:" <> table_hashid}) do
    Table.reset_roman_vote(Table.get_by_hashid(table_hashid))
    broadcast_users(socket)
  end

  def broadcast_roman_result(socket, result) do
    broadcast! socket, "roman_result", %{result: result}
  end

  def count_vote(socket = %{topic: "table:" <> table_hashid}, vote) do
    table_id = Obfuscator.decode(table_hashid)
    current_roman_timestamp = Table.current_roman_timestamp(table_id)
    Presence.update(socket, socket.assigns.username, %{last_vote: [current_roman_timestamp, vote]})

    roman_result = Presence.list(socket)
    |> RomanCounter.result(current_roman_timestamp)

    if roman_result != :inconclusive do
      broadcast_roman_result(socket, roman_result)
      Table.reset_roman_vote(Repo.get!(Table, table_id))
    end
    broadcast_users(socket)
  end

  def connected_users(socket = %{topic: "table:" <> table_hashid}) do
    table_id = Obfuscator.decode(table_hashid)
    current_roman_timestamp = Table.current_roman_timestamp(table_id)
    socket
    |> Presence.list
    |> RomanCounter.users_to_json(current_roman_timestamp)
  end

  def topics_payload(table_hashid) do
    table_id = Obfuscator.decode(table_hashid)
    table = Repo.get!(Table, table_id)
    %{topics: topics(table_hashid), pollClosed: table.poll_closed}
  end

  def broadcast_users(socket) do
    broadcast! socket, "users", %{users: connected_users(socket)}
  end

  def handle_info({:after_join, _params}, socket = %{topic: "table:" <> table_hashid}) do
    track_new_user(socket)
    push socket, "topics", topics_payload(table_hashid)
    {:noreply, socket}
  end

  def handle_in("dot_vote", %{"topic_id" => topic_id}, socket = %{topic: "table:" <> table_hashid}) do
    Repo.insert!(%DotVote{topic_id: topic_id})
    broadcast! socket, "topics", %{topics: topics(table_hashid)}
    {:noreply, socket}
  end

  def handle_in("close_poll", _, socket = %{topic: "table:" <> table_hashid}) do
    table_id = Obfuscator.decode(table_hashid)
    table = Repo.get!(Table, table_id)
    change = Ecto.Changeset.change(table, poll_closed: true)
    Repo.update(change)
    broadcast! socket, "topics", topics_payload(table_hashid)
    {:noreply, socket}
  end

  def handle_in("complete_topic", _, socket = %{topic: "table:" <> table_hashid}) do
    table_id = Obfuscator.decode(table_hashid)
    table = Repo.get!(Table, table_id)

    topics_and_dot_votes =
      table
      |> Table.topics_query
      |> Topic.incomplete
      |> Ecto.Query.first
      |> Repo.one
      |> Topic.complete!

    broadcast! socket, "topics", topics_payload(table_hashid)
    {:noreply, socket}
  end

  def handle_in("new_topic", %{"body" => body}, socket = %{topic: "table:" <> table_hashid}) do
    table_id = Obfuscator.decode(table_hashid)
    topic = %Topic{table_id: table_id, name: body}
    Repo.insert!(topic)
    broadcast! socket, "topics", topics_payload(table_hashid)
    {:reply, :ok, socket}
  end

  def handle_in("roman_vote", %{"vote" => vote}, socket) do
    count_vote(socket, vote)
    {:reply, :ok, socket}
  end

  def handle_in("clear_votes", _params, socket) do
    clear_votes(socket)
    {:reply, :ok, socket}
  end

  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end
end
