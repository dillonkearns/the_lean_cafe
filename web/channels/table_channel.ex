defmodule TheLeanCafe.TableChannel do
  use Phoenix.Channel
  alias TheLeanCafe.{Presence, Table, Topic, Repo, TopicView, RomanCounter}

  intercept ["new_topic", "topics", "close_poll"]

  def join("table:" <> _room_name, params, socket) do
    send(self, {:after_join, params})
    {:ok, socket}
  end

  def handle_info({:after_join, _params}, socket = %{topic: "table:" <> table_hashid}) do
    track_new_user(socket)
    table_id = Obfuscator.decode(table_hashid)
    table = Repo.get!(Table, table_id)
    push socket, "topics", topics_payload(table)
    {:noreply, socket}
  end

  def handle_in(message, params, socket = %{topic: "table:" <> table_hashid}) do
    table_id = Obfuscator.decode(table_hashid)
    table = Repo.get!(Table, table_id)
    handle(message, params, socket, table)
  end

  defp handle("dot_vote", %{"topic_id" => topic_id}, socket, table) do
    Topic.vote_for(topic_id) |> Repo.insert!
    table_hashid = Obfuscator.encode(table.id)
    broadcast! socket, "topics", %{topics: topics(table_hashid)}
    {:noreply, socket}
  end

  defp handle("close_poll", _, socket, table) do
    change = Ecto.Changeset.change(table, poll_closed: true)
    Repo.update(change)
    broadcast! socket, "topics", topics_payload(table)
    {:noreply, socket}
  end

  defp handle("complete_topic", _, socket, table) do
    current_topic =
      table
      |> Table.current_topic
      |> Repo.one

    if current_topic do
      current_topic
      |> Topic.complete
      |> Repo.update!
    end

    broadcast! socket, "topics", topics_payload(table)
    {:noreply, socket}
  end

  defp handle("new_topic", %{"body" => body}, socket, table) do
    topic = %Topic{table: table, name: body}
    Repo.insert!(topic)
    broadcast! socket, "topics", topics_payload(table)
    {:reply, :ok, socket}
  end

  defp handle("rename_topic", %{"body" => new_name, "id" => topic_id}, socket, table) do
    topic = Repo.get!(Topic, topic_id)
    Topic.changeset(topic, %{name: new_name}) |> Repo.update!

    broadcast! socket, "topics", topics_payload(table)
    {:reply, :ok, socket}
  end

  defp handle("roman_vote", %{"vote" => vote}, socket, table) do
    count_vote(socket, vote)
    {:reply, :ok, socket}
  end

  defp handle("clear_votes", _params, socket, table) do
    Table.reset_roman_vote(table)
    broadcast_users(socket)
    {:reply, :ok, socket}
  end

  defp topics(table_hashid) do
    table_id = Obfuscator.decode(table_hashid)
    table = Repo.get!(Table, table_id)

    topics_and_dot_votes =
      table
      |> Table.topics_query
      |> Topic.with_vote_counts
      |> Repo.all

    Phoenix.View.render_to_string(TopicView, "index.html", topics_and_dot_votes: topics_and_dot_votes)
  end

  defp track_new_user(socket) do
    Presence.track(socket, socket.assigns.username, %{
      joined_at: :os.system_time(:milli_seconds)
    })
    broadcast_users(socket)
  end

  defp broadcast_roman_result(socket, result) do
    broadcast! socket, "roman_result", %{result: result}
  end

  defp count_vote(socket = %{topic: "table:" <> table_hashid}, vote) do
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

  defp connected_users(socket = %{topic: "table:" <> table_hashid}) do
    table_id = Obfuscator.decode(table_hashid)
    current_roman_timestamp = Table.current_roman_timestamp(table_id)
    socket
    |> Presence.list
    |> RomanCounter.users_to_json(current_roman_timestamp)
  end

  defp topics_payload(table) do
    table_hashid = Obfuscator.encode(table.id)
    %{topics: topics(table_hashid), pollClosed: table.poll_closed}
  end

  defp broadcast_users(socket) do
    broadcast! socket, "users", %{users: connected_users(socket)}
  end

  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end
end
