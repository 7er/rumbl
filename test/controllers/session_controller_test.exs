defmodule Rumbl.SessionControllerTest do
  use Rumbl.ConnCase
  alias Rumbl.User

  setup do
    changeset = User.registration_changeset(
      %User{},
      %{"username" => "7er", "password" => "fleksnes", "name" => "Syver"})
    Repo.insert!(changeset)
    :ok
  end

  test "DELETE /", %{conn: conn} do    
    conn = post conn, "/sessions", %{"session" => %{"username" => "7er", "password" => "fleksnes"}}
    #assert response(conn, 200) =~ "Welcome to Rumbl.io!"
    assert redirected_to(conn, 302) == "/"
    assert get_flash(conn, :info) == "Welcome back, Syver!"
  end  
end
