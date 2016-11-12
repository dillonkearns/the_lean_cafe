defmodule TheLeanCafe.Channels.TableChannelTest do
  use TheLeanCafe.ChannelCase

  import TheLeanCafe.Factory
  alias TheLeanCafe.{Table, Repo}

  setup do
    table = Repo.insert!(%Table{})
    {:ok, socket} = connect(TheLeanCafe.UserSocket, %{})
    {:ok, socket: socket, table: table}
  end

  test "adds topic after receiving new_topic", %{socket: socket, table: table} do
    {:ok, _reply, socket} = subscribe_and_join_table(socket, table)
    assert_push "topics", %{incomplete: "", complete: ""}
    topic_count = length(TheLeanCafe.Repo.all(TheLeanCafe.Topic))

    ref = push socket, "new_topic", %{body: "Some interesting topic"}
    assert_reply ref, :ok
    assert_broadcast "topics", topics
    assert length(TheLeanCafe.Repo.all(TheLeanCafe.Topic)) == topic_count + 1
    new_topic_html = topics.incomplete
    assert new_topic_html =~ ~r(<li>.*Some interesting topic.*</li>)s
  end

  test "renames topic", %{socket: socket, table: table} do
    {:ok, _reply, socket} = subscribe_and_join_table(socket, table)
    topic = insert(:topic, table: table)

    ref = push socket, "rename_topic", %{id: topic.id, body: "New topic text"}
    assert_reply ref, :ok
    assert_broadcast "topics", topics
    new_topic_html = topics.incomplete
    assert new_topic_html =~ ~r(<li>.*New topic text.*</li>)s
  end

  test "changes state", %{socket: socket, table: table} do
    {:ok, _reply, socket} = subscribe_and_join_table(socket, table)

    ref = push socket, "change_state", %{to_state: "vote"}
    assert_reply ref, :ok
    assert_broadcast "states", states
    assert states.states_html =~ ~r(<a[^>]*selected[^<]*Vote.*</a>)s
    assert Repo.get!(TheLeanCafe.Table, table.id).state == "vote"
  end

  test "broadcasts new timer start time", %{socket: socket, table: table} do
    {:ok, _reply, socket} = subscribe_and_join_table(socket, table)

    ref = push socket, "start_timer", %{}
    assert_reply ref, :ok
    assert_broadcast "countdown_to", countdown_response
    now = Timex.now

    countdown_to = Repo.get!(TheLeanCafe.Table, table.id).countdown_to
    assert_times_equal countdown_to, Timex.parse!(countdown_response.countdown_to, "%FT%T%:z", :strftime)
    assert_n_minutes_later(now, countdown_to, 4)
  end

  test "sends countdown_to message when joining a room with a timer", %{socket: socket, table: table} do
    table
    |> Table.start_timer
    |> Repo.update!

    {:ok, _reply, _socket} = subscribe_and_join_table(socket, table)

    assert_push "countdown_to", countdown_response

    countdown_to = Repo.get!(TheLeanCafe.Table, table.id).countdown_to
    assert_times_equal countdown_to, Timex.parse!(countdown_response.countdown_to, "%FT%T%:z", :strftime)
  end

  test "generates anonymous username", %{socket: socket, table: table} do
    {:ok, _reply, _socket} = subscribe_and_join_table(socket, table)
    assert_push "username", response
    assert response.username == "Anonymous Bear"
  end

  def assert_n_minutes_later(earlier_time, later_time, n) do
    diff_seconds = Timex.diff(later_time, earlier_time, :seconds)
    threshold = 5
    expected_diff_seconds = n * 60
    off_by_minutes = (diff_seconds - expected_diff_seconds) / 60
    assert_in_delta(diff_seconds, expected_diff_seconds, threshold,
      "Off by #{off_by_minutes} minutes")
  end

  defp assert_times_equal(time1, time2) do
    assert Timex.diff(time1, time2, :seconds) < 5
  end

  defp subscribe_and_join_table(socket, table) do
    table_hashid = TheLeanCafe.Table.hashid(table)
    subscribe_and_join(socket, "table:#{table_hashid}", %{})
  end

end
