defmodule TheLeanCafe.Channels.TableChannelTest do
  use TheLeanCafe.ChannelCase

  setup do
    table = TheLeanCafe.Repo.insert!(%TheLeanCafe.Table{})
    {:ok, socket} = connect(TheLeanCafe.UserSocket, %{})
    {:ok, socket: socket, table: table}
  end

  test "adds topic after receiving new_topic", %{socket: socket, table: table} do
    table_hashid = TheLeanCafe.Table.hashid(table)
    {:ok, _reply, socket} = subscribe_and_join(socket, "table:#{table_hashid}", %{})
    assert_push "topics", %{topics: []}
    topic_count = length(TheLeanCafe.Repo.all(TheLeanCafe.Topic))

    ref = push socket, "new_topic", %{body: "Some interesting topic"}
    assert_reply ref, :ok
    assert_broadcast "topics", topics
    assert length(TheLeanCafe.Repo.all(TheLeanCafe.Topic)) == topic_count + 1
    new_topic_html = topics.topics |> Enum.at(0)
    assert new_topic_html =~ ~r(<li>.*Some interesting topic</li>)s
  end
end
