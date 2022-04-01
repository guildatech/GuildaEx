defmodule Guilda.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query, warn: false
  alias Guilda.Accounts.Events
  alias Guilda.Accounts.User
  alias Guilda.Accounts.UserNotifier
  alias Guilda.Accounts.UserToken
  alias Guilda.Accounts.UserTOTP
  alias Guilda.AuditLog
  alias Guilda.Repo

  @pubsub Guilda.PubSub

  def subscribe(user_id) do
    Phoenix.PubSub.subscribe(@pubsub, topic(user_id))
  end

  def unsubscribe(user_id) do
    Phoenix.PubSub.unsubscribe(@pubsub, topic(user_id))
  end

  defp topic(user_id), do: "user:#{user_id}"

  ## Database getters

  @doc """
  Checks if an account was created using Telegram and does not have a hashed password.
  """
  def is_legacy_account?(%User{} = user) do
    query = from u in User, where: not is_nil(u.telegram_id) and is_nil(u.hashed_password) and u.id == ^user.id
    Repo.exists?(query)
  end

  @doc """
  Gets a user by telegram_id.

  ## Examples

      iex> get_user_by_telegram_id("11223344")
      %User{}

      iex> get_user_by_telegram_id("11111111")
      nil

  """
  def get_user_by_telegram_id(telegram_id) when is_binary(telegram_id) do
    Repo.get_by(User, telegram_id: telegram_id)
  end

  def get_user_by_telegram_id(_other), do: nil

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%AuditLog{}, %{field: value})
      {:ok, %User{}}

      iex> register_user(%AuditLog{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(audit_context, attrs) do
    user_changeset = User.registration_changeset(%User{}, attrs)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, user_changeset)
    |> AuditLog.multi(audit_context, "accounts.register_user", fn context, %{user: user} ->
      %{context | user: user, params: %{email: user.email}}
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Upgrade a user account that didn't have an email or password set.

  ## Examples

      iex> set_email_and_password(%AuditLog{}, %{field: value})
      {:ok, %User{}}

      iex> set_email_and_password(%AuditLog{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def set_email_and_password(audit_context, user, attrs) do
    user_changeset = User.registration_changeset(user, attrs)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, user_changeset)
    |> AuditLog.multi(audit_context, "accounts.add_email_and_password", fn context, %{user: user} ->
      %{context | user: user, params: %{email: user.email}}
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Link a provider to a user account.

  ## Examples

      iex> connect_provider(audit_context, user, :provider, provider_uid)
      {:ok, %User{}}

      iex> connect_provider(audit_context, user, :provider, provider_uid)
      {:error, %Ecto.Changeset{}}

  """
  def connect_provider(audit_context, %User{} = user, :telegram, telegram_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.provider_changeset(user, %{telegram_id: telegram_id}))
    |> AuditLog.multi(audit_context, "accounts.providers.connect", %{
      user_id: user.id,
      provider: "telegram",
      uid: telegram_id
    })
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Unlink a provider to a user account.

  ## Examples

      iex> disconnect_provider(audit_context, user, :provider)
      {:ok, %User{}}

      iex> disconnect_provider(audit_context, user, :provider)
      {:error, %Ecto.Changeset{}}

  """
  def disconnect_provider(audit_context, %User{} = user, :telegram) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.provider_changeset(user, %{telegram_id: nil}))
    |> AuditLog.multi(audit_context, "accounts.providers.disconnect", %{
      user_id: user.id,
      provider: "telegram",
      uid: user.telegram_id
    })
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false)
  end

  ## Settings

  @doc """
  Returns a User changeset that is valid if the current password is valid.

  It returns a changeset. The changeset has an action if the current password
  is not nil.
  """
  def validate_user_current_password(user, current_password) do
    user
    |> Ecto.Changeset.change()
    |> User.validate_current_password(current_password)
    |> attach_action_if_current_password(current_password)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email and validates the password.

  ## Examples

      iex> change_user_email(user, password, attrs)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, current_password \\ nil, attrs \\ %{}) do
    User.email_changeset(user, attrs)
    |> User.validate_current_password(current_password)
    |> attach_action_if_current_password(current_password)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(audit_context, user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(audit_context, user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(audit_context, user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, [context]))
    |> AuditLog.multi(audit_context, "accounts.update_email.finish", %{user_id: user.id, email: email})
  end

  @doc """
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_update_email_instructions(audit_context, user, current_email, &Routes.user_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(audit_context, %User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    {:ok, _} =
      Ecto.Multi.new()
      |> AuditLog.multi(audit_context, "accounts.update_email.init", %{
        user_id: user.id,
        email: user.email
      })
      |> Ecto.Multi.insert(:user_token, user_token)
      |> Repo.transaction()

    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, current_password \\ nil, attrs \\ %{}) do
    user
    |> User.password_changeset(attrs, hash_password: false)
    |> User.validate_current_password(current_password)
    |> attach_action_if_current_password(current_password)
  end

  @doc """
  Applies update action for changing user password.

  ## Examples

      iex> apply_user_password(user, valid_current_password, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> apply_user_password(user, invalid_current_password, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_password(user, password, attrs) do
    user
    |> User.password_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  defp attach_action_if_current_password(changeset, nil),
    do: changeset

  defp attach_action_if_current_password(changeset, _),
    do: Map.replace!(changeset, :action, :validate)

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(audit_context, user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> AuditLog.multi(audit_context, "accounts.update_password", %{user_id: user.id})
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Location

  def set_lng_lat(audit_context, %User{} = user, lng, lat) do
    {new_lng, new_lat} = Guilda.Geo.random_nearby_lng_lat(lng, lat, 10)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.location_changeset(user, %Geo.Point{coordinates: {new_lng, new_lat}, srid: 4326}))
    |> AuditLog.multi(audit_context, "accounts.location.share", %{
      user_id: user.id
    })
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} ->
        {lng, lat} = user.geom.coordinates
        broadcast!(user, %Events.LocationChanged{user: user})
        broadcast!("member_location", %Events.LocationAdded{lat: lat, lng: lng})
        {:ok, user}

      {:error, :user, changeset, _} ->
        {:error, changeset}
    end
  end

  def remove_location(audit_context, %User{} = user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.location_changeset(user, nil))
    |> AuditLog.multi(audit_context, "accounts.location.revoke", %{
      user_id: user.id
    })
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} ->
        broadcast!(user, %Events.LocationChanged{user: user})
        {:ok, user}

      {:error, :user, changeset, _} ->
        {:error, changeset}
    end
  end

  def list_users_locations do
    from(u in User)
    |> where([u], not is_nil(u.geom))
    |> select([u], u.geom)
    |> Repo.all()
    |> Enum.map(fn %{coordinates: {lng, lat}} -> %{lng: lng, lat: lat} end)
  end

  ## TOTP

  @doc """
  Gets the %UserTOTP{} entry, if any.
  """
  def get_user_totp(user) do
    Repo.get_by(UserTOTP, user_id: user.id)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing user TOTP.

  ## Examples

      iex> change_user_totp(%UserTOTP{})
      %Ecto.Changeset{data: %UserTOTP{}}

  """
  def change_user_totp(totp, attrs \\ %{}) do
    UserTOTP.changeset(totp, attrs)
  end

  @doc """
  Updates the TOTP secret.

  The secret is a random 20 bytes binary that is used to generate the QR Code to
  enable 2FA using auth applications. It will only be updated if the OTP code
  sent is valid.

  ## Examples

      iex> upsert_user_totp(%UserTOTP{secret: <<...>>}, code: "123456")
      {:ok, %Ecto.Changeset{data: %UserTOTP{}}}

  """
  def upsert_user_totp(audit_context, totp, attrs) do
    totp_changeset =
      totp
      |> UserTOTP.changeset(attrs)
      |> UserTOTP.ensure_backup_codes()
      # If we are updating, let's make sure the secret
      # in the struct propagates to the changeset.
      |> Ecto.Changeset.force_change(:secret, totp.secret)

    audit_action = if is_nil(totp.id), do: "enable", else: "update"

    Ecto.Multi.new()
    |> Ecto.Multi.insert_or_update(:totp, totp_changeset)
    |> AuditLog.multi(audit_context, "accounts.user_totp.#{audit_action}", %{
      user_id: totp.user_id
    })
    |> Repo.transaction()
    |> case do
      {:ok, %{totp: totp}} -> {:ok, totp}
      {:error, :totp, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Regenerates the user backup codes for totp.

  ## Examples

      iex> regenerate_user_totp_backup_codes(%UserTOTP{})
      %UserTOTP{backup_codes: [...]}

  """
  def regenerate_user_totp_backup_codes(audit_context, totp) do
    {:ok, updated_totp} =
      Repo.transaction(fn ->
        AuditLog.audit!(audit_context, "accounts.user_totp.regenerate_backup_codes", %{
          user_id: totp.user_id
        })

        totp
        |> Ecto.Changeset.change()
        |> UserTOTP.regenerate_backup_codes()
        |> Repo.update!()
      end)

    updated_totp
  end

  @doc """
  Disables the TOTP configuration for the given user.
  """
  def delete_user_totp(audit_context, user_totp) do
    Repo.transaction(fn ->
      AuditLog.audit!(audit_context, "accounts.user_totp.disable", %{user_id: user_totp.user_id})
      Repo.delete!(user_totp)
    end)

    :ok
  end

  @doc """
  Validates if the given TOTP code is valid.
  """
  def validate_user_totp(audit_context, user, code) do
    totp = Repo.get_by!(UserTOTP, user_id: user.id)

    cond do
      UserTOTP.valid_totp?(totp, code) ->
        AuditLog.audit!(audit_context, "accounts.user_totp.validated", %{user_id: user.id})
        :valid_totp

      changeset = UserTOTP.validate_backup_code(totp, code) ->
        {:ok, totp} =
          Repo.transaction(fn ->
            AuditLog.audit!(audit_context, "accounts.user_totp.validated_with_backup_code", %{
              user_id: user.id
            })

            Repo.update!(changeset)
          end)

        {:valid_backup_code, Enum.count(totp.backup_codes, &is_nil(&1.used_at))}

      true ->
        AuditLog.audit!(audit_context, "accounts.user_totp.invalid_code_used", %{user_id: user.id})

        :invalid
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  @doc """
  Sets the user's admin flag to true.
  """
  def give_admin(%User{} = user) do
    from(u in User, where: u.id == ^user.id)
    |> Repo.update_all(set: [is_admin: true])
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &Routes.user_confirmation_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &Routes.user_confirmation_url(conn, :edit, &1))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(audit_context, user, &Routes.user_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(audit_context, %User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")

    {:ok, _} =
      Ecto.Multi.new()
      |> AuditLog.multi(audit_context, "accounts.reset_password.init", %{user_id: user.id})
      |> Ecto.Multi.insert(:user_token, user_token)
      |> Repo.transaction()

    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(audit_context, user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(audit_context, user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(audit_context, user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> AuditLog.multi(audit_context, "accounts.reset_password.finish", %{user_id: user.id})
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  defp broadcast!("member_location", msg) do
    Phoenix.PubSub.broadcast!(@pubsub, "member_location", {__MODULE__, msg})
  end

  defp broadcast!(%User{} = user, msg) do
    Phoenix.PubSub.broadcast!(@pubsub, topic(user.id), {__MODULE__, msg})
  end
end
