defmodule Guilda.Accounts.UserNotifier do
  @moduledoc """
  This module contains all functions related to user notifications.
  """
  use Phoenix.Swoosh,
    view: GuildaWeb.UserNotifierView,
    layout: {GuildaWeb.LayoutView, :email}

  alias Guilda.Mailer
  import GuildaWeb.Gettext

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, template, assigns) do
    email =
      new()
      |> to(recipient)
      |> from({"GuildaTech", "guildatech@loworbitlabs.com"})
      |> subject(subject)
      |> render_body(template, assigns)
      |> GuildaWeb.Mjml.compile!()

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, gettext("Confirmation instructions"), :confirmation_instructions, %{user: user, url: url})
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, gettext("Reset password instructions"), :reset_password_instructions, %{user: user, url: url})
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, gettext("Update email instructions"), :update_email_instructions, %{user: user, url: url})
  end
end
