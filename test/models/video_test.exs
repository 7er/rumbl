defmodule Rumbl.VideoTest do
  use Rumbl.ModelCase

  alias Rumbl.Video

  @valid_attrs %{url: "http://youtu.be/a_video",
                 title: "the video",
                 description: "some content"}
  @invalid_attrs %{category_id: "12345"}

  test "changeset with valid attributes" do
    changeset = Video.changeset(%Video{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Video.changeset(%Video{}, @invalid_attrs)
    refute changeset.valid?
  end
end
