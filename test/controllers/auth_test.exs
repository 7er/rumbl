defmodule Rumbl.AuthTest do
  use Rumbl.ConnCase
  alias Rumbl.Auth

  setup %{conn: conn} do
    conn = conn
    |> bypass_through(Rumbl.Router, :browser)
    |> get("/")
    {:ok, %{conn: conn}}
  end    

  test "authenticate user halts when no current_user exists", %{conn: conn} do
    conn = Auth.authenticate(conn, [])    
    assert conn.halted
    assert get_flash(conn, :error) == "You must be logged in to access that page"
  end

  test "authenticate_user continues when the current_user exists", %{conn: conn} do
    conn = conn
    |> assign(:current_user, %Rumbl.User{})
    |> Auth.authenticate([])
    refute conn.halted
  end

  test "login puts the user in the session", %{conn: conn} do
    login_conn = conn
    |> Auth.login(%Rumbl.User{id: 123})
    |> send_resp(:ok, "")
    next_conn = get(login_conn, "/")
    assert get_session(next_conn, :user_id) == 123
  end

  test "logout drops the session", %{conn: conn} do
    logout_conn =
      conn
    |> put_session(:user_id, 123)
    |> Auth.logout()
    |> send_resp(:ok, "")
    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :user_id)
  end  
  test "call places user from session into assigns", %{conn: conn} do
    user = insert_user()  
    conn =
      conn
    |> put_session(:user_id, user.id)  
    |> Auth.call(Repo)  

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session sets current_user assign to nil", %{conn: conn} do
    conn = Auth.call(conn, Repo)
    assert conn.assigns.current_user == nil
  end

  test "call does nothing if current_user assign is already present", %{conn: conn} do
    # this feature is useful for testing authenticated controller actions
    # by setting the current_user assign to a user
    user = insert_user()
    conn = conn
    |> assign(:current_user, user)
    |> Auth.call(Repo)
    assert conn.assigns.current_user.id == user.id
  end
end

