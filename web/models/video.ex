defmodule Rumbl.Video do
  use Rumbl.Web, :model

  @primary_key {:id, Rumbl.Permalink, autogenerate: true}
  schema "videos" do
    field :url, :string
    field :title, :string
    field :description, :string
    belongs_to :user, Rumbl.User
    belongs_to :category, Rumbl.Category
    has_many :annotations, Rumbl.Annotation
    timestamps
  end

  @required_fields ~w(url title description)
  @optional_fields ~w(category_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> assoc_constraint(:category)
  end

end

defimpl Phoenix.Param, for: Rumbl.Video do
  defp slugify(title) do
    title
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-")
  end
  
  def to_param(%{title: title, id: id}) do
    "#{id}-#{slugify(title)}"
  end
end
