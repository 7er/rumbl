defmodule Rumbl.CategoryRepoTest do
  use Rumbl.ModelCase
  alias Rumbl.Category

  test "alphabetical/1 orders by name" do
    for each <- ["c", "a", "b"] do
      Repo.insert!(%Category{name: each})
    end
    query = Category.alphabetical(Category)
    query = from(
      c in query,
      select: c.name,
      where: c.name in ["c", "a", "b"])
    assert Repo.all(query) == ~w(a b c)
  end
end

