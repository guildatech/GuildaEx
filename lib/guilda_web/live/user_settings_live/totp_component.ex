defmodule GuildaWeb.UserSettingsLive.TOTPComponent do
  @moduledoc """
  Renders TOTP form in the Settings page.
  """
  use GuildaWeb, :live_component

  alias Guilda.Accounts

  @qrcode_size 264

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.content_section title={gettext("2FA")} subtitle={gettext("Even more security goodies.")}>
        <.card>
          <:title>
            <h3><%= gettext("Two-factor authentication") %></h3>
            <%= if @current_totp do %>
              <div class="flex-shrink-0">
                <.badge label={gettext("Enabled")} color="success" size="lg" />
              </div>
            <% end %>
          </:title>
          <%= if @backup_codes, do: render_backup_codes(assigns) %>
          <%= if @editing_totp, do: render_totp_form(assigns), else: render_enable_form(assigns) %>
        </.card>
      </.content_section>
    </div>
    """
  end

  defp render_backup_codes(assigns) do
    ~H"""
    <.modal
      show
      id="totp-backup-codes-modal"
      on_cancel={
        JS.push("hide_backup_codes", target: @myself)
        |> hide_modal("totp-backup-codes-modal")
      }
    >
      <:title><%= gettext("Backup Codes") %></:title>
      <p class="max-w-xl prose text-gray-600">
        <%= raw(
          gettext(
            "Two-factor authentication is enabled. In case you lose access to your phone, you will need one of the backup codes below. <strong>Keep these backup codes safe</strong>. You can also generate new codes at any time."
          )
        ) %>
      </p>

      <div class="py-5 my-4 bg-gray-100 rounded-md">
        <%= for backup_code <- @backup_codes do %>
          <div class="font-mono text-center">
            <h4>
              <%= if backup_code.used_at do %>
                <del class="text-gray-400"><%= backup_code.code %></del>
              <% else %>
                <%= backup_code.code %>
              <% end %>
            </h4>
          </div>
        <% end %>
      </div>

      <:cancel><%= gettext("Close") %></:cancel>
      <:actions>
        <.button
          :if={@editing_totp}
          id="btn-regenerate-backup"
          variant="outline"
          class="inline-flex justify-center w-full font-medium sm:w-auto sm:text-sm sm:ml-3"
          phx-click="regenerate_backup_codes"
          phx-target={@myself}
          data-confirm="Are you sure you want to regenerate your backup codes?"
        >
          <%= gettext("Regenerate backup codes") %>
        </.button>
      </:actions>
    </.modal>
    """
  end

  defp render_totp_form(assigns) do
    ~H"""
    <.form :let={f} for={@totp_changeset} id="form-update-totp" phx-submit="update_totp" phx-target={@myself}>
      <%= if @secret_display == :as_text do %>
        <p class="max-w-xl prose text-gray-600">
          To <%= if @current_totp, do: "change", else: "enable" %> two-factor authentication,
          enter the secret below into your two-factor authentication app in your phone.
        </p>

        <div id="totp-secret" class="p-5 my-4 font-mono text-lg bg-gray-100 rounded-md">
          <%= format_secret(@editing_totp.secret) %>
        </div>

        <p class="max-w-xl mb-4 prose text-gray-600">
          Or <a href="#" phx-click="display_secret_as_qrcode" phx-target={@myself}>scan the QR Code</a> instead.
        </p>
      <% else %>
        <p class="max-w-xl prose text-gray-600">
          To <%= if @current_totp, do: "change", else: "enable" %> two-factor authentication,
          scan the image below with the two-factor authentication app in your phone
          and then enter the authentication code at the bottom. If you can't use QR Code,
          <a href="#" id="btn-manual-secret" phx-click="display_secret_as_text" phx-target={@myself}>enter your secret</a>
          manually.
        </p>

        <div class="my-4 text-center">
          <div class="d-inline-block">
            <%= generate_qrcode(@qrcode_uri) %>
          </div>
        </div>
      <% end %>

      <div class="grid grid-cols-6 gap-6">
        <div class="col-span-6 sm:col-span-4">
          <.input field={{f, :code}} type="text" label={gettext("Authentication code")} autocomplete="off" />
        </div>
      </div>
      <div class="mt-5 space-x-3">
        <.button type="submit" color="primary" phx-disable-with={gettext("Verifying...")}>
          <%= gettext("Verify code") %>
        </.button>
        <.button phx-target={@myself} phx-click="cancel_totp"><%= gettext("Cancel") %></.button>
      </div>

      <%= if @current_totp do %>
        <p class="max-w-xl mt-6 prose text-gray-600">
          You may also
          <a href="#" id="btn-show-backup" phx-click="show_backup_codes" phx-target={@myself}>
            see your available backup codes
          </a>
          or
          <a
            href="#"
            id="btn-disable-totp"
            phx-click="disable_totp"
            phx-target={@myself}
            data-confirm="Are you sure you want to disable Two-factor authentication?"
          >
            disable two-factor authentication
          </a>
          altogether.
        </p>
      <% end %>
    </.form>
    """
  end

  defp render_enable_form(assigns) do
    ~H"""
    <.form
      :let={f}
      for={@user_changeset}
      id="form-submit-totp"
      phx_change="change_totp"
      phx-submit="submit_totp"
      phx-target={@myself}
    >
      <div class="grid grid-cols-6 gap-6">
        <div class="col-span-6 sm:col-span-4">
          <.input
            field={{f, :current_password}}
            type="password"
            id="current_password_for_totp"
            phx-debounce="blur"
            name="current_password"
            value={@current_password}
            label={
              if @current_totp,
                do: gettext("Enter your current password to change 2FA"),
                else: gettext("Enter your current password to enable 2FA")
            }
          />
        </div>
      </div>
      <.button type="submit" class="mt-5">
        <%= if @current_totp do %>
          <%= gettext("Change two-factor authentication") %>
        <% else %>
          <%= gettext("Enable two-factor authentication") %>
        <% end %>
      </.button>
    </.form>
    """
  end

  @impl true
  def update(assigns, socket) do
    if socket.assigns[:current_user] do
      {:ok, socket}
    else
      {:ok,
       socket
       |> assign(:audit_context, assigns.audit_context)
       |> assign(:current_user, assigns.current_user)
       |> assign(:backup_codes, nil)
       |> reset_assigns(Accounts.get_user_totp(assigns.current_user))}
    end
  end

  @impl true
  def handle_event("show_backup_codes", _, socket) do
    {:noreply, assign(socket, :backup_codes, socket.assigns.editing_totp.backup_codes)}
  end

  @impl true
  def handle_event("hide_backup_codes", _, socket) do
    {:noreply, assign(socket, :backup_codes, nil)}
  end

  @impl true
  def handle_event("regenerate_backup_codes", _, socket) do
    totp =
      Guilda.Accounts.regenerate_user_totp_backup_codes(
        socket.assigns.audit_context,
        socket.assigns.editing_totp
      )

    socket =
      socket
      |> assign(:backup_codes, totp.backup_codes)
      |> assign(:editing_totp, totp)

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_totp", %{"user_totp" => params}, socket) do
    editing_totp = socket.assigns.editing_totp
    audit_context = socket.assigns.audit_context

    case Accounts.upsert_user_totp(audit_context, editing_totp, params) do
      {:ok, current_totp} ->
        {:noreply,
         socket
         |> reset_assigns(current_totp)
         |> assign(:backup_codes, current_totp.backup_codes)}

      {:error, changeset} ->
        {:noreply, assign(socket, totp_changeset: changeset)}
    end
  end

  @impl true
  def handle_event("disable_totp", _, socket) do
    :ok = Accounts.delete_user_totp(socket.assigns.audit_context, socket.assigns.editing_totp)
    {:noreply, reset_assigns(socket, nil)}
  end

  @impl true
  def handle_event("display_secret_as_qrcode", _, socket) do
    {:noreply, assign(socket, :secret_display, :as_qrcode)}
  end

  @impl true
  def handle_event("display_secret_as_text", _, socket) do
    {:noreply, assign(socket, :secret_display, :as_text)}
  end

  @impl true
  def handle_event("change_totp", %{"current_password" => current_password}, socket) do
    {:noreply, assign_user_changeset(socket, current_password)}
  end

  @impl true
  def handle_event("submit_totp", %{"current_password" => current_password}, socket) do
    socket = assign_user_changeset(socket, current_password)

    if socket.assigns.user_changeset.valid? do
      user = socket.assigns.current_user
      editing_totp = socket.assigns.current_totp || %Accounts.UserTOTP{user_id: user.id}
      app = "GuildaTech"
      secret = NimbleTOTP.secret()
      qrcode_uri = NimbleTOTP.otpauth_uri("#{app}:#{user.email}", secret, issuer: app)

      editing_totp = %{editing_totp | secret: secret}
      totp_changeset = Accounts.change_user_totp(editing_totp)

      socket =
        socket
        |> assign(:editing_totp, editing_totp)
        |> assign(:totp_changeset, totp_changeset)
        |> assign(:qrcode_uri, qrcode_uri)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("cancel_totp", _, socket) do
    {:noreply, reset_assigns(socket, socket.assigns.current_totp)}
  end

  defp reset_assigns(socket, totp) do
    socket
    |> assign(:current_totp, totp)
    |> assign(:secret_display, :as_qrcode)
    |> assign(:editing_totp, nil)
    |> assign(:totp_changeset, nil)
    |> assign(:qrcode_uri, nil)
    |> assign_user_changeset(nil)
  end

  defp assign_user_changeset(socket, current_password) do
    user = socket.assigns.current_user

    socket
    |> assign(:current_password, current_password)
    |> assign(:user_changeset, Accounts.validate_user_current_password(user, current_password))
  end

  # sobelow_skip ["XSS.Raw"]
  defp generate_qrcode(uri) do
    uri
    |> EQRCode.encode()
    |> EQRCode.svg(width: @qrcode_size)
    |> raw()
  end

  # sobelow_skip ["XSS.Raw"]
  defp format_secret(secret) do
    secret
    |> Base.encode32(padding: false)
    |> String.graphemes()
    |> Enum.map(&maybe_highlight_digit/1)
    |> Enum.chunk_every(4)
    |> Enum.intersperse(" ")
    |> raw()
  end

  defp maybe_highlight_digit(char) do
    case Integer.parse(char) do
      :error -> char
      _ -> ~s(<span class="text-primary">#{char}</span>)
    end
  end
end
