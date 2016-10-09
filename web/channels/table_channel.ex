defmodule TheLeanCafe.TableChannel do
  use Phoenix.Channel

  def join(room_name, _auth_msg, socket) do
  intercept ["new_topic", "topics"]

    {:ok, socket}
  end

  def handle_in("new_topic", %{"body" => body}, socket) do
    broadcast! socket, "new_topic", %{body: body}
    {:noreply, socket}
  end

  def handle_out("new_topic", payload, socket) do
    push socket, "new_topic", payload
    {:noreply, socket}
  end
end
