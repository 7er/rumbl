# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

alias Rumbl.Repo
alias Rumbl.Category
alias Rumbl.User

for category <- ~w(Action Drama Romance Comedy Sci-fi) do
  unless Repo.get_by(Category, name: category) do
    Repo.insert!(%Category{name: category})
  end
end

unless Repo.get_by(User, username: "wolfram") do
  Repo.insert!(%User{name: "Worlfram", username: "wolfram"})
end
