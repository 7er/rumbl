defmodule Rumbl.User do
  use Rumbl.Web, :model
  # defstruct [:id, :name, :username, :password]
  schema "users" do
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps
  end

  def changeset(user, params \\ :empty) do
    user
    |> cast(params, ~w(name username), [])
    |> unique_constraint(:username)
    |> validate_length(:username, min: 1, max: 20)
  end
end

