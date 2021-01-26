defmodule GuildaWeb.Podcasts.PodcastEpisodeLive.FormComponent do
  @moduledoc """
  LiveView Component to display a form for a podcast episode.
  """
  use GuildaWeb, :live_component

  alias Guilda.Podcasts

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(:cover, accept: ~w(.jpg .jpeg .png), external: &presign_cover/2)
     |> allow_upload(:file, accept: ~w(.mp3), max_file_size: 100_000_000, external: &presign_file/2)}
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
    episode_params =
      episode_params
      |> put_cover_params(socket)
      |> put_file_params(socket)

    case Podcasts.create_episode(episode_params, &consume_files(socket, &1)) do
      {:ok, _episode} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Episódio salvo com sucesso."))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_episode(socket, :edit, episode_params) do
    episode_params =
      episode_params
      |> put_cover_params(socket)
      |> put_file_params(socket)

    case Podcasts.update_episode(socket.assigns.episode, episode_params, &consume_files(socket, &1)) do
      {:ok, _episode} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Episódio atualizado com sucesso."))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp s3_key(entry), do: "#{Application.get_env(:guilda, :environment)}/#{entry.client_name}"
  defp s3_host, do: "//#{bucket()}.s3.amazonaws.com"
  defp bucket, do: System.fetch_env!("S3_BUCKET")

  defp signed_fields(entry, max_file_size) do
    GuildaWeb.SimpleS3Upload.sign_form_upload(config(), bucket(),
      key: s3_key(entry),
      content_type: entry.client_type,
      max_file_size: max_file_size,
      expires_in: :timer.hours(1)
    )
  end

  defp config do
    %{
      region: System.fetch_env!("AWS_REGION"),
      access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
      secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
    }
  end

  defp presign_cover(entry, socket) do
    presign_entry(entry, socket.assigns.uploads.cover.max_file_size, socket)
  end

  defp presign_file(entry, socket) do
    presign_entry(entry, socket.assigns.uploads.file.max_file_size, socket)
  end

  defp presign_entry(entry, max_file_size, socket) do
    {:ok, fields} = signed_fields(entry, max_file_size)

    meta = %{uploader: "S3", key: s3_key(entry), url: s3_host(), fields: fields}
    {:ok, meta, socket}
  end

  defp put_cover_params(params, socket) do
    case uploaded_entries(socket, :cover) do
      {[entry], []} ->
        Map.merge(
          params,
          %{
            "cover_url" => Path.join(s3_host(), s3_key(entry)),
            "cover_name" => entry.client_name,
            "cover_size" => entry.client_size,
            "cover_type" => entry.client_type
          }
        )

      _ ->
        params
    end
  end

  defp put_file_params(params, socket) do
    case uploaded_entries(socket, :file) do
      {[entry], []} ->
        Map.merge(
          params,
          %{
            "file_url" => Path.join(s3_host(), s3_key(entry)),
            "file_name" => entry.client_name,
            "file_size" => entry.client_size,
            "file_type" => entry.client_type
          }
        )

      _ ->
        params
    end
  end

  def consume_files(socket, episode) do
    consume_uploaded_entries(socket, :cover, fn _meta, _entry -> :ok end)
    consume_uploaded_entries(socket, :file, fn _meta, _entry -> :ok end)

    {:ok, episode}
  end
end
