defmodule Rumbl.RoomChannel do
  use Phoenix.Channel

  def join("rooms:lobby", _message, socket) do    
    {:ok, socket}
  end
  def join("rooms:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast! socket, "new_msg", %{body: body}
    {:noreply, socket}
  end

  def handle_in("typing", %{}, socket) do
    broadcast! socket, "typing", %{}
    {:noreply, socket}
  end
end
