defmodule GuildaWeb.Podcasts.PodcastEpisodeLive.FormComponent do
  use GuildaWeb, :live_component

  alias Guilda.Podcasts

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(:cover, accept: ~w(.jpg .jpeg .png), external: &presign_cover/2)
     |> allow_upload(:file, accept: ~w(.mp3), max_file_size: 70_000_000, external: &presign_file/2)}
  end

  @impl true
  def update(%{episode: episode} = assigns, socket) do
    changeset = Podcasts.change_episode(episode)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"episode" => episode_params}, socket) do
    changeset =
      socket.assigns.episode
      |> Podcasts.change_episode(episode_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"episode" => episode_params}, socket) do
    save_episode(socket, socket.assigns.action, episode_params)
  end

  def handle_event("cancel-cover-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :cover, ref)}
  end

  def handle_event("cancel-file-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :file, ref)}
  end

  defp save_episode(socket, :new, episode_params) do
    episode =
      socket.assigns.episode
      |> put_cover(socket)
      |> put_file(socket)

    case Podcasts.create_episode(episode, episode_params, &consume_files(socket, &1)) do
      {:ok, _episode} ->
        {:noreply,
         socket
         |> put_flash(:info, "Episódio salvo com sucesso.")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_episode(socket, :edit, episode_params) do
    episode =
      socket.assigns.episode
      |> put_cover(socket)
      |> put_file(socket)

    case Podcasts.update_episode(episode, episode_params, &consume_files(socket, &1)) do
      {:ok, _episode} ->
        {:noreply,
         socket
         |> put_flash(:info, "Episódio atualizado com sucesso.")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp s3_key(entry), do: "public/#{entry.uuid}.#{ext(entry)}"
  defp s3_host, do: "//#{bucket()}.s3.amazonaws.com"
  defp bucket, do: System.fetch_env!("S3_BUCKET")

  defp ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end

  defp presign_cover(entry, socket) do
    uploads = socket.assigns.uploads

    config = %{
      region: System.fetch_env!("AWS_REGION"),
      access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
      secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
    }

    {:ok, fields} =
      GuildaWeb.SimpleS3Upload.sign_form_upload(config, bucket(),
        key: s3_key(entry),
        content_type: entry.client_type,
        max_file_size: uploads.cover.max_file_size,
        expires_in: :timer.hours(1)
      )

    meta = %{uploader: "S3", key: s3_key(entry), url: s3_host(), fields: fields}
    {:ok, meta, socket}
  end

  defp presign_file(entry, socket) do
    uploads = socket.assigns.uploads

    config = %{
      region: System.fetch_env!("AWS_REGION"),
      access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
      secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
    }

    {:ok, fields} =
      GuildaWeb.SimpleS3Upload.sign_form_upload(config, bucket(),
        key: s3_key(entry),
        content_type: entry.client_type,
        max_file_size: uploads.file.max_file_size,
        expires_in: :timer.hours(1)
      )

    meta = %{uploader: "S3", key: s3_key(entry), url: s3_host(), fields: fields}
    {:ok, meta, socket}
  end

  defp put_cover(episode, socket) do
    case uploaded_entries(socket, :cover) do
      {[entry], []} ->
        url = Path.join(s3_host(), s3_key(entry))

        %{
          episode
          | cover_url: url,
            cover_name: entry.client_name,
            cover_size: entry.client_size,
            cover_type: entry.client_type
        }

      _ ->
        episode
    end
  end

  defp put_file(episode, socket) do
    case uploaded_entries(socket, :file) do
      {[entry], []} ->
        url = Path.join(s3_host(), s3_key(entry))

        %{
          episode
          | file_url: url,
            file_name: entry.client_name,
            file_size: entry.client_size,
            file_type: entry.client_type
        }

      _ ->
        episode
    end
  end

  def consume_files(socket, episode) do
    consume_uploaded_entries(socket, :cover, fn _meta, _entry -> :ok end)
    consume_uploaded_entries(socket, :file, fn _meta, _entry -> :ok end)

    {:ok, episode}
  end
end
