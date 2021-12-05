defmodule GuildaWeb.UserSettingLive do
  @moduledoc """
  LiveView to update a user's settings.
  """
  use GuildaWeb, :live_view

  alias Guilda.Accounts

  @impl true
  def mount(params, session, socket) do
    socket = assign_defaults(socket, params, session)
    user = socket.assigns.current_user

    socket =
      socket
      |> assign(:email_changeset, Accounts.change_user_email(user))

    {:ok, socket}
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
end
