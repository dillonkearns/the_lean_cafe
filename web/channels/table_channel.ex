defmodule TheLeanCafe.TableChannel do
  use Phoenix.Channel
  alias TheLeanCafe.{Presence, Table, Topic, Repo, TopicView, RomanCounter}

  import Ecto.Query

  intercept ["new_topic", "topics"]

  def join("table:" <> _room_name, params, socket) do
    send(self, {:after_join, params})
    {:ok, socket}
  end

  def handle_info({:after_join, _params}, socket = %{topic: "table:" <> table_hashid}) do
    track_new_user(socket)
    table_id = Obfuscator.decode(table_hashid)
    table = Repo.get!(Table, table_id)
    push socket, "topics", topics_payload(table)
    states_html = Phoenix.View.render_to_string(TheLeanCafe.TableView, "_state_group.html", %{current_state: table.state})
    push socket, "states", %{states_html: states_html}
    {:noreply, socket}
  end

  def handle_in(message, params, socket = %{topic: "table:" <> table_hashid}) do
    table_id = Obfuscator.decode(table_hashid)
    table = Repo.get!(Table, table_id)
    handle(message, params, socket, table)
  end

  defp handle("dot_vote", %{"topic_id" => topic_id}, socket, table = %Table{state: "vote"}) do
    Topic.vote_for(topic_id) |> Repo.insert!
    broadcast_topics socket, table
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

    broadcast_topics socket, table

    {:noreply, socket}
  end

  defp handle("new_topic", %{"body" => body}, socket, table) do
    topic = %Topic{table: table, name: body}
    Repo.insert!(topic)
    broadcast_topics socket, table
    {:reply, :ok, socket}
  end

  defp handle("rename_topic", %{"body" => new_name, "id" => topic_id}, socket, table) do
    topic = Repo.get!(Topic, topic_id)
    Topic.changeset(topic, %{name: new_name}) |> Repo.update!

    broadcast_topics socket, table
    {:reply, :ok, socket}
  end

  defp handle("roman_vote", %{"vote" => vote}, socket, table) do
    Presence.update(socket, socket.assigns.username, %{last_vote: [table.current_roman_timestamp, vote]})

    roman_result = Presence.list(socket)
    |> RomanCounter.result(last_vote: table.current_roman_timestamp)

    if roman_result != :inconclusive do
      broadcast_roman_result(socket, roman_result)
      Table.reset_roman_vote(table)
    end
    broadcast_users(socket)
    {:reply, :ok, socket}
  end

  defp handle("topic_vote", %{"vote" => vote}, socket, table) do
    current_topic = table |> Table.current_topic |> Repo.one

    Presence.update(socket, socket.assigns.username, %{topic_vote: [current_topic.id, vote]})

    roman_result = Presence.list(socket)
    |> RomanCounter.result(topic_vote: current_topic.id)

    outstanding = RomanCounter.outstanding(Presence.list(socket), topic_vote: current_topic.id)
    IO.puts "Got roman_result: #{roman_result}, outstanding = #{outstanding} @@@@@@@@@"

    if roman_result != :inconclusive do
      broadcast_roman_result(socket, roman_result)
    end

    if roman_result == :- do
      Repo.get!(Topic, current_topic.id)
      |> Topic.complete
      |> Repo.update!
      broadcast_topics socket, table
    end
    {:reply, :ok, socket}
  end

  defp handle("clear_votes", _params, socket, table) do
    Table.reset_roman_vote(table)
    broadcast_users(socket)
    {:reply, :ok, socket}
  end

  defp handle("change_state", %{"to_state" => to_state}, socket, table) do
    table = table |> Table.changeset(%{state: to_state}) |> Repo.update!
    states_html = Phoenix.View.render_to_string(TheLeanCafe.TableView, "_state_group.html", %{current_state: table.state})
    broadcast! socket, "states", %{states_html: states_html}
    broadcast_topics socket, table
    {:reply, :ok, socket}
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

  defp connected_users(socket = %{topic: "table:" <> table_hashid}) do
    table_id = Obfuscator.decode(table_hashid)
    current_roman_timestamp = Table.current_roman_timestamp(table_id)

    socket
    |> Presence.list
    |> RomanCounter.users_to_json(last_vote: current_roman_timestamp)
  end

  defp topics_payload(table) do
    %{complete: topics(table, true), incomplete: topics(table, false), state: table.state}
  end

  defp topics(table, completed) do
    topics_and_dot_votes =
      table
      |> Table.topics_query
      |> where([topic], topic.completed == ^completed)
      |> Topic.with_vote_counts
      |> Repo.all

    Phoenix.View.render_to_string(TopicView, "index.html", topics_and_dot_votes: topics_and_dot_votes, hide_votes: table.state == "brainstorm")
  end

  defp broadcast_users(socket) do
    broadcast! socket, "users", %{users: connected_users(socket)}
  end

  defp broadcast_topics(socket, table) do
    broadcast! socket, "topics", topics_payload(table)
  end

  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end
end
