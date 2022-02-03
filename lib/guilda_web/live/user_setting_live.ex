defmodule GuildaWeb.UserSettingLive do
  @moduledoc """
  LiveView to update a user's settings.
  """
  use GuildaWeb, :live_view

  alias Guilda.Accounts

  on_mount GuildaWeb.RequireUser

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :email_changeset, Accounts.change_user_email(socket.assigns.current_user))}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, gettext("Configurações"))}
  end

  @impl true
  def handle_event(
        "update-email",
        %{"user" => user_params},
        socket
      ) do
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_update_email_instructions(
          applied_user,
          user.email,
          &Routes.user_settings_url(GuildaWeb.Endpoint, :confirm_email, &1)
        )

        {:noreply,
         socket
         |> put_flash(
           :info,
           "A link to confirm your e-mail change has been sent to the new address."
         )
         |> assign(:email_changeset, Accounts.change_user_email(user))}

      {:error, changeset} ->
        {:noreply, assign(socket, email_changeset: changeset)}
    end
  end

  def handle_event("remove-location", _params, socket) do
    user = socket.assigns.current_user

    case Accounts.remove_location(user) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Sua localização foi removida com sucesso."))
         |> assign(:current_user, user)}

      {:error, changeset} ->
        {:noreply, put_flash(socket, :error, gettext("Não foi possível remover sua localização."))}
    end
  end
end
