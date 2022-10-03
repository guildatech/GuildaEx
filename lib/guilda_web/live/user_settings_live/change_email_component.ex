defmodule GuildaWeb.UserSettingsLive.ChangeEmailComponent do
  @moduledoc """
  Component used to update a user's email address.
  """
  use GuildaWeb, :live_component

  alias Guilda.Accounts

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(:audit_context, assigns.audit_context)
     |> assign(:current_user, assigns.current_user)
     |> assign(:email_changeset, Accounts.change_user_email(assigns.current_user))
     |> assign(:current_password, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
    <.content_section title={gettext("Email")} subtitle={gettext("We don't send spam.")}>
      <%= if !@current_user.confirmed_at do %>
        <div class="p-4 mb-5 rounded-md bg-yellow-50">
          <div class="flex">
            <div class="flex-shrink-0">
              <!-- Heroicon name: solid/exclamation -->
              <svg class="w-5 h-5 text-yellow-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-yellow-800"><%= gettext("Attention needed") %></h3>
              <div class="mt-2 text-sm text-yellow-700">
                <p><%= gettext("Please confirm your email address to access all features.") %></p>
                <.button id="resend-confirmation-btn" phx-update="ignore" class="mt-2 font-bold" phx-click={JS.push("resend-confirmation") |> JS.hide()} phx-disable-with={gettext("Sending...")}><%= gettext("Resend confirmation instructions.") %></.button>
              </div>
            </div>
          </div>
        </div>
      <% end %>
      <.card>
        <.form id="update-email-form" let={f} for={@email_changeset} phx-submit="update-email" phx-change="validate-email" phx-target={@myself}>
          <div class="grid grid-cols-6 gap-6">
            <div class="col-span-6 sm:col-span-4">
              <div class="space-y-6">
                <.input field={{f, :email}} type="text" label={gettext("Email")} />
                <.input field={{f, :current_password}} type="password" name="current_password" label={gettext("Current password")} />
              </div>
            </div>
          </div>
        </.form>
        <:footer>
          <.button type="submit" color="primary" form="update-email-form"><%= gettext("Change email") %></.button>
        </:footer>
      </.card>
    </.content_section>
    </div>
    """
  end

  def handle_event(
        "validate-email",
        %{"user" => user_params, "current_password" => current_password},
        socket
      ) do
    email_changeset = Accounts.change_user_email(socket.assigns.current_user, current_password, user_params)

    socket =
      socket
      |> assign(:current_password, current_password)
      |> assign(:email_changeset, email_changeset)

    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event(
        "update-email",
        %{"user" => user_params, "current_password" => current_password},
        socket
      ) do
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, current_password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_update_email_instructions(
          socket.assigns.audit_context,
          applied_user,
          user.email,
          &Routes.user_settings_url(GuildaWeb.Endpoint, :confirm_email, &1)
        )

        send(
          self(),
          {:flash, :info, gettext("A link to confirm your email change has been sent to the new address.")}
        )

        {:noreply,
         socket
         |> assign(:email_changeset, Accounts.change_user_email(user))
         |> assign(:current_password, "")}

      {:error, email_changeset} ->
        socket =
          socket
          |> assign(:current_password, current_password)
          |> assign(:email_changeset, email_changeset)

        {:noreply, socket}
    end
  end
end
