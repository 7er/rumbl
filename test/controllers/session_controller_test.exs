defmodule Rumbl.SessionControllerTest do
  use Rumbl.ConnCase

  setup do
    user = insert_user(%{username: "7er", password: "fleksnes", name: "Syver"})
    {:ok, user: user}
  end

  def create_session(conn, user) do
    post conn, "/sessions", %{"session" => %{"username" => user.username, "password" => user.password}}
  end

  test "POST /sessions", %{conn: conn, user: user} do
    conn = post(conn, "/sessions", %{"session" => %{"username" => user.username, "password" => user.password}})
    assert redirected_to(conn, 302) == "/"
    assert get_flash(conn, :info) == "Welcome back, Syver!"
  end

  test "DELETE /sessions/:id", %{conn: conn, user: user} do
    conn = create_session(conn, user)
    conn = delete(conn, "/sessions/#{user.id}")
    assert redirected_to(conn, 302) == "/"
  end

  test "DELETE /sessions/:id with wrong id", %{conn: conn, user: user} do
    conn = create_session(conn, user)
    conn = delete(conn, "/sessions/#{user.id + 1}")
    assert response(conn, 400) == "Invalid request"
  end
end
