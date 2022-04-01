defmodule GuildaWeb.UserSettingLive do
  @moduledoc """
  LiveView to update a user's settings.
  """
  use GuildaWeb, :live_view

  alias Guilda.Accounts

  on_mount GuildaWeb.MountHooks.RequireUser

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Accounts.subscribe(socket.assigns.current_user.id)
    end

    {:ok,
     assign(socket,
       password_changeset: Accounts.change_user_password(socket.assigns.current_user),
       is_legacy_account?: Accounts.is_legacy_account?(socket.assigns.current_user),
       password_trigger_action: false,
       current_password: nil,
       bot_name: GuildaWeb.AuthController.telegram_bot_username()
     )}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, gettext("Settings"))}
  end

  @impl Phoenix.LiveView
  def handle_event(
        "validate-password",
        %{"current_password" => current_password, "user" => user_params},
        socket
      ) do
    password_changeset = Accounts.change_user_password(socket.assigns.current_user, current_password, user_params)

    socket =
      socket
      |> assign(:current_password, current_password)
      |> assign(:password_changeset, password_changeset)

    {:noreply, socket}
  end

  def handle_event(
        "update-password",
        %{"current_password" => current_password, "user" => user_params},
        socket
      ) do
    socket = assign(socket, :current_password, current_password)

    socket.assigns.current_user
    |> Accounts.apply_user_password(current_password, user_params)
    |> case do
      {:ok, _} ->
        {:noreply, assign(socket, :password_trigger_action, true)}

      {:error, password_changeset} ->
        {:noreply, assign(socket, :password_changeset, password_changeset)}
    end
  end

  def handle_event("remove-location", _params, socket) do
    user = socket.assigns.current_user

    case Accounts.remove_location(socket.assigns.audit_context, user) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Your location was removed successfully."))
         |> assign(:current_user, user)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, gettext("Failed to remove your location."))}
    end
  end

  def handle_event("disconnect-telegram", _params, socket) do
    user = socket.assigns.current_user

    case Accounts.disconnect_provider(socket.assigns.audit_context, user, :telegram) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Your Telegram account was successfully disconnected."))
         |> assign(:current_user, user)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, gettext("Failed to remove your location."))}
    end
  end

  def handle_event("resend-confirmation", _params, socket) do
    Accounts.deliver_user_confirmation_instructions(
      socket.assigns.current_user,
      &Routes.user_confirmation_url(socket, :edit, &1)
    )

    {:noreply,
     put_flash(socket, :info, gettext("You will receive an email with instructions to confirm your account shortly."))}
  end

  @impl Phoenix.LiveView
  def handle_info({Accounts, %Accounts.Events.LocationChanged{} = update}, socket) do
    {:noreply, assign(socket, current_user: update.user)}
  end

  def handle_info({Accounts, _}, socket), do: {:noreply, socket}
end
