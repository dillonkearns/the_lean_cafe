defmodule TheLeanCafe.TableChannel do
  use Phoenix.Channel

  intercept ["new_topic", "topics"]

  def join(_room_name, params, socket) do
    send(self, {:after_join, params})
    {:ok, socket}
  end

  def topics do
    table =
      TheLeanCafe.Repo.get!(TheLeanCafe.Table, 1)
      |> TheLeanCafe.Repo.preload(:topics)
    table.topics
    |> Enum.map(&(&1.name))
    |> Enum.reverse
  end

  def handle_info({:after_join, _params}, socket) do
    push socket, "topics", %{topics: topics}
    {:noreply, socket}
  end

  def handle_in("new_topic", %{"body" => body}, socket) do
    topic = %TheLeanCafe.Topic{table_id: 1, name: body}
    TheLeanCafe.Repo.insert!(topic)
    broadcast! socket, "new_topic", %{body: body}
    {:noreply, socket}
  end

  def handle_out("new_topic", payload, socket) do
    push socket, "new_topic", payload
    {:noreply, socket}
  end
end
