defmodule TheLeanCafe.TableChannel do
  use Phoenix.Channel

  # def join("table:hardcoded", _auth_msg, socket) do
  def join(room_name, _auth_msg, socket) do
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
