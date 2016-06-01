defmodule Rumbl.VideoChannel do
  use Rumbl.Web, :channel
  alias Rumbl.Video
  alias Rumbl.Annotation
  alias Rumbl.AnnotationView

  def join("videos:" <> video_id_string, params, socket) do
    last_seen_id = params["last_seen_id"] || 0
    video_id = String.to_integer(video_id_string)
    video = Repo.get!(Video, video_id)

    annotations = Repo.all(
      from a in assoc(video, :annotations),
      where: a.id > ^last_seen_id,
      order_by: [asc: a.at, asc: a.id],
      limit: 200,
      preload: [:user])
    resp = %{annotations: Phoenix.View.render_many(
                annotations,
                AnnotationView,
                "annotation.json")}
    {:ok, resp, assign(socket, :video_id, video.id)}
  end

  def handle_info(:ping, socket) do
    count = socket.assigns[:count] || 1
    push(socket, "ping", %{count: count})
    {:noreply, assign(socket, :count, count + 1)}
  end

  def handle_in(event, params, socket) do
    user = Repo.get(User, socket.assigns.user_id)
    handle_in_with_user(event, params, user, socket)
  end

  def handle_in_with_user("new_annotation", params, user, socket) do
    changeset =
      user
      |> build_assoc(:annotations, video_id: socket.assigns.video_id)
      |> Annotation.changeset(params)
    case Repo.insert(changeset) do
      {:ok, annotation} ->
        broadcast_annotation(socket, annotation)
        Task.start_link(fn -> compute_additional_info(annotation, socket) end)
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset.errors}}, socket}
    end
  end

  def broadcast_annotation(socket, annotation) do
    annotation = Repo.preload(annotation, :user)
    rendered_annotation = Phoenix.View.render(
      AnnotationView,
      "annotation.json",
      %{annotation: annotation})
    broadcast!(
      socket,
      "new_annotation",
      rendered_annotation)
  end

  defp compute_additional_info(annotation, socket) do
    IO.puts("got here")
    for result <- Rumbl.InfoSys.compute(annotation.body, limit: 1, timeout: 10_000) do
      attrs = %{url: result.url, body: result.text, at: annotation.at}
      info_changeset =
        Repo.get_by!(User, username: result.backend)
        |> build_assoc(:annotations, video_id: annotation.video_id)
        |> Annotation.changeset(attrs)
      case Repo.insert(info_changeset) do
        {:ok, info_annotation} -> broadcast_annotation(socket, info_annotation)
        {:error, _changeset} -> :ignore
      end
    end
  end
end
