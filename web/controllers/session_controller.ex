defmodule Rumbl.SessionController do
  use Rumbl.Web, :controller
  
  plug :authenticate when action in [:index, :delete]

  def index(conn, _) do
    render conn, "index.html"
  end

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"username" => user, "password" => pass}}) do
    case Rumbl.Auth.login_by_username_and_pass(conn, user, pass, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back, #{conn.assigns.current_user.name}!")
        |> redirect(to: page_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, %{"id" => string_id}) do
    {id, ""} = Integer.parse(string_id)
    if (conn.assigns.current_user.id != id) do
      conn 
      |> put_status(400)
      |> text("Invalid request")
    else
      conn
      |> put_flash(:info, "Bye, #{conn.assigns.current_user.name}!")
      |> Rumbl.Auth.logout_current_user
      |> redirect(to: page_path(conn, :index))
    end
  end
end
