defmodule Guilda.Accounts.User do
  @moduledoc """
  The User's schema.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :telegram_id, :string, null: false
    field :username, :string
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :confirmed_at, :naive_datetime
    field :is_admin, :boolean, default: false
    field :geom, Geo.PostGIS.Geometry

    timestamps()
  end

  @required_registration_fields ~w(telegram_id)a
  @optional_registration_fields ~w(last_name username first_name)a

  @doc """
  A user changeset for registration.
  """
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, @required_registration_fields ++ @optional_registration_fields)
    |> validate_required(@required_registration_fields)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, Guilda.Repo)
    |> unique_constraint(:email)
  end

  @doc """
  Sets the user's location.
  """
  def location_changeset(user, geom) do
    change(user, geom: geom)
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
    |> case do
      %{errors: [email: {"can't be blank", [validation: :required]}]} = changeset ->
        changeset

      %{changes: %{email: _}} = changeset ->
        changeset

      %{} = changeset ->
        add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end
end
