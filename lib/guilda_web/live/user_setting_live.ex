defmodule GuildaWeb.UserSettingLive do
  @moduledoc """
  LiveView to update a user's settings.
  """
  use GuildaWeb, :live_view

  alias Guilda.Accounts

  on_mount GuildaWeb.MountHooks.RequireUser

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Accounts.subscribe(socket.assigns.current_user.id)
    end

    {:ok,
     assign(socket,
       email_changeset: Accounts.change_user_email(socket.assigns.current_user),
       password_changeset: Accounts.change_user_password(socket.assigns.current_user),
       bot_name: GuildaWeb.AuthController.telegram_bot_username()
     )}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, gettext("Settings"))}
  end

  @impl true
  def handle_event(
        "update-email",
        %{"user" => user_params} = params,
        socket
      ) do
    %{"user" => %{"current_password" => password} = user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
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
           gettext("A link to confirm your e-mail change has been sent to the new address.")
         )
         |> assign(:email_changeset, Accounts.change_user_email(user))}

      {:error, changeset} ->
        {:noreply, assign(socket, email_changeset: changeset)}
    end
  end

  def handle_event(
        "update-password",
        %{"user" => user_params} = params,
        socket
      ) do
    %{"user" => %{"current_password" => password} = user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Password updated successfully."))
         |> assign(:password_changeset, Accounts.change_user_password(user))}

      {:error, changeset} ->
        {:noreply, assign(socket, password_changeset: changeset)}
    end
  end

  def handle_event("remove-location", _params, socket) do
    user = socket.assigns.current_user

    case Accounts.remove_location(user) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Your location was removed successfully."))
         |> assign(:current_user, user)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, gettext("Failed to remove your location."))}
    end
  end

  @impl true
  def handle_info({Accounts, %Accounts.Events.LocationChanged{} = update}, socket) do
    {:noreply, assign(socket, current_user: update.user)}
  end

  def handle_info({Accounts, _}, socket), do: {:noreply, socket}
end
