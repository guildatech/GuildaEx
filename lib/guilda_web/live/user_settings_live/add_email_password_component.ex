defmodule GuildaWeb.UserSettingsLive.AddEmailPasswordComponent do
  @moduledoc """
  Component used to add email/password to legacy accounts.
  """
  use GuildaWeb, :live_component

  alias Guilda.Accounts

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(:audit_context, assigns.audit_context)
     |> assign(:current_user, assigns.current_user)
     |> assign(:changeset, Accounts.change_user_registration(assigns.current_user))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.content_section
        title={gettext("Set Email and Password")}
        subtitle={gettext("Upgrade from a Telegram-only login to access enhanced features.")}
        }
      >
        <div class="p-4 rounded-md bg-yellow-50">
          <div class="flex">
            <div class="flex-shrink-0">
              <!-- Heroicon name: solid/exclamation -->
              <svg
                class="w-5 h-5 text-yellow-400"
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 20 20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path
                  fill-rule="evenodd"
                  d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"
                  clip-rule="evenodd"
                />
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-yellow-800"><%= gettext("Attention needed") %></h3>
              <div class="mt-2 text-sm text-yellow-700">
                <p><%= gettext("You're signed in using an old account that does not have an email or password set.") %></p>
                <p>
                  <%= gettext("Please add an email to your account to access newer accounts feature like 2FA and Webauthn.") %>
                </p>
              </div>
            </div>
          </div>
        </div>
        <.card class="mt-5">
          <.form id="add-email-form" :let={f} for={@changeset} phx-submit="add-email" phx-target={@myself}>
            <div class="grid grid-cols-6 gap-6">
              <div class="col-span-6 sm:col-span-4">
                <.input field={{f, :email}} type="text" />
                <.input field={{f, :password}} type="password" />
              </div>
            </div>
          </.form>
          <:footer>
            <.button type="submit" form="add-email-form"><%= gettext("Save") %></.button>
          </:footer>
        </.card>
      </.content_section>
    </div>
    """
  end

  @impl true
  def handle_event(
        "add-email",
        %{"user" => user_params},
        socket
      ) do
    user = socket.assigns.current_user

    case Accounts.set_email_and_password(socket.assigns.audit_context, user, user_params) do
      {:ok, user} ->
        Accounts.deliver_user_confirmation_instructions(
          user,
          &Routes.user_confirmation_url(socket, :edit, &1)
        )

        {:noreply,
         socket
         |> put_flash(
           :info,
           gettext("A link to confirm your email change has been sent to the new address.")
         )
         |> push_redirect(to: Routes.user_settings_path(socket, :index))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
