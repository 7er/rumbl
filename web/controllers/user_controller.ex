defmodule Rumbl.UserController do
  use Rumbl.Web, :controller
  alias Rumbl.User

  plug :authenticate when action in [:index, :show]
  plug :scrub_params, "user" when action in [:create, :update]
  
  def index(conn, _params) do
    users = Repo.all(User)
    render conn, users: users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(User, id)
    render conn, user: user
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, changeset: changeset
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    Repo.delete!(user)
    conn
    |> put_flash(:info, "Deleted #{user.name}!")
    |> redirect(to: user_path(conn, :index))
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> Rumbl.Auth.login(user)
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
