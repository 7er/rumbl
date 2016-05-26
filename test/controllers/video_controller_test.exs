defmodule Rumbl.VideoControllerTest do
  use Rumbl.ConnCase

  alias Rumbl.Video
  @valid_attrs %{url: "http://youtu.be", title: "vid", description: "a vid", }
  @invalid_attrs %{title: "invalid"}

  defp video_count(query), do: Repo.one(from v in query, select: count(v.id))

  setup %{conn: conn} = config do
    username = config[:login_as]
    if username do
      user = insert_user(username: username)
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end    
  end

  @tag login_as: "max"
  test "lists all user's videos on index", %{conn: conn, user: user} do
    user_video  = insert_video(user, title: "funny cats")
    other_video = insert_video(insert_user(username: "other"), title: "another video")

    conn = get conn, video_path(conn, :index)
    assert html_response(conn, 200) =~ ~r/Listing videos/
    assert String.contains?(conn.resp_body, user_video.title)
    refute String.contains?(conn.resp_body, other_video.title)
  end

  test "requires user authentication on all actions" do
    conn = conn()
    Enum.each([
      get(conn, video_path(conn, :new)),
      get(conn, video_path(conn, :index)),
      get(conn, video_path(conn, :show, "123")),
      get(conn, video_path(conn, :edit, "123")),
      put(conn, video_path(conn, :update, "123", %{})),
      post(conn, video_path(conn, :create, %{})),
      delete(conn, video_path(conn, :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: "max"
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, video_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing videos"
  end

  @tag login_as: "max"
  test "renders form for new video", %{conn: conn} do
    conn = get conn, video_path(conn, :new)
    assert html_response(conn, 200) =~ "New video"
  end

  @tag login_as: "max"
  test "creates video and redirects when data is valid", %{conn: conn, user: user} do
    conn = post conn, video_path(conn, :create), video: @valid_attrs
    assert redirected_to(conn) == video_path(conn, :index)
    assert Repo.get_by!(Video, @valid_attrs).user_id == user.id
  end

  @tag login_as: "max"
  test "does not create video and renders errors when data is invalid", %{conn: conn} do
    count_before = video_count(Video)
    conn = post conn, video_path(conn, :create), video: @invalid_attrs
    assert html_response(conn, 200) =~ "New video"
    assert video_count(Video) == count_before
  end

  @tag login_as: "max"
  test "shows chosen video", %{conn: conn, user: user} do
    conn = get conn, video_path(
      conn, :show,
      insert_video(user, title: "funny cats"))
    assert html_response(conn, 200) =~ "Show video"
  end

  @tag login_as: "max"
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent :not_found, fn ->
      get(conn, video_path(conn, :show, -1))
    end
  end

  @tag login_as: "max"
  test "renders form for editing chosen video", %{conn: conn, user: user} do
    video = insert_video(user, title: "funny cats")
    conn = get conn, video_path(conn, :edit, video)
    assert html_response(conn, 200) =~ "Edit video"
  end

  @tag login_as: "max"
  test "updates chosen video and redirects when data is valid", %{conn: conn, user: user} do
    video = insert_video(user, title: "funny cats")
    conn = put conn, video_path(conn, :update, video), video: @valid_attrs
    assert redirected_to(conn) == video_path(conn, :show, video)
    assert Repo.get_by(Video, @valid_attrs)
  end

  @tag login_as: "max"
  test "does not update chosen video and renders errors when data is invalid", %{conn: conn, user: user} do
    video = insert_video(user, title: "funny cats")
    conn = put conn, video_path(conn, :update, video), video: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit video"
  end

  @tag login_as: "max"
  test "deletes chosen video", %{conn: conn, user: user} do
    video = insert_video(user, title: "funny cats")
    conn = delete conn, video_path(conn, :delete, video)
    assert redirected_to(conn) == video_path(conn, :index)
    refute Repo.get(Video, video.id)
  end

  @tag login_as: "max"
  test "authorizes actions against access by other users", %{conn: conn} do
    owner = insert_user(username: "sneaky")
    video = insert_video(owner, @valid_attrs)
    assert_error_sent :not_found, fn ->
      get(conn, video_path(conn, :show, video))
    end
    assert_error_sent :not_found, fn ->
      get(conn, video_path(conn, :edit, video))
    end
    assert_error_sent :not_found, fn ->
      put(conn, video_path(conn, :update, video, video: @valid_attrs))
    end
    assert_error_sent :not_found, fn ->
      delete(conn, video_path(conn, :delete, video))
    end
  end  
end
