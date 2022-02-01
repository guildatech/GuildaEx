defmodule Guilda.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Guilda.Accounts.User
  alias Guilda.Accounts.UserNotifier
  alias Guilda.Accounts.UserToken
  alias Guilda.Repo

  ## Database getters

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
  Registers a user or updates their attributes.

  ## Examples

      iex> upsert_user(%{field: value})
      {:ok, %User{}}

      iex> upsert_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def upsert_user(attrs) do
    telegram_id = Map.get(attrs, :telegram_id) || Map.get(attrs, "telegram_id")
    user = get_user_by_telegram_id(telegram_id)

    (user || %User{})
    |> User.registration_changeset(attrs)
    |> Repo.insert_or_update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs)
  end

  @doc """
  Emulates that the e-mail will change without actually changing
  it in the database.
  """
  def apply_user_email(user, attrs) do
    user
    |> User.email_changeset(attrs)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset = user |> User.email_changeset(%{email: email}) |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, [context]))
  end

  @doc """
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_update_email_instructions(user, current_email, &Routes.user_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  ## Location
  def set_lng_lat(%User{} = user, lng, lat) do
    {new_lng, new_lat} = Guilda.Geo.random_nearby_lng_lat(lng, lat, 10)

    user
    |> User.location_changeset(%Geo.Point{coordinates: {new_lng, new_lat}, srid: 4326})
    |> Repo.update()
  end

  def remove_location(%User{} = user) do
    user
    |> User.location_changeset(nil)
    |> Repo.update()
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
end
