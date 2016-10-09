defmodule TheLeanCafe.TableChannel do
  use Phoenix.Channel

  intercept ["new_topic", "topics"]

  def join("table:" <> room_name, params, socket) do
    send(self, {:after_join, params})
    {:ok, socket}
  end

  def topics(table_hashid) do
    table_id = Obfuscator.decode(table_hashid)
    table =
      TheLeanCafe.Repo.get!(TheLeanCafe.Table, table_id)
      |> TheLeanCafe.Repo.preload(:topics)
    table.topics
    |> Enum.map(&(&1.name))
    |> Enum.reverse
  end

  def handle_info({:after_join, _params}, socket = %{topic: "table:" <> table_hashid}) do
    push socket, "topics", %{topics: topics(table_hashid)}
    {:noreply, socket}
  end

  def handle_in("new_topic", %{"body" => body}, socket = %{topic: "table:" <> table_hashid}) do
    table_id = Obfuscator.decode(table_hashid)
    topic = %TheLeanCafe.Topic{table_id: table_id, name: body}
    TheLeanCafe.Repo.insert!(topic)
    broadcast! socket, "new_topic", %{body: body}
    {:noreply, socket}
  end

  def handle_out("new_topic", payload, socket) do
    push socket, "new_topic", payload
    {:noreply, socket}
  end
end
