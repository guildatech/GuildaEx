defmodule Guilda.Podcasts.Episode do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "podcast_episodes" do
    field :title, :string
    field :slug, :string
    field :description, :string
    field :hosts, :string
    field :aired_date, :date
    field :cover_url, :string
    field :cover_name, :string
    field :cover_type, :string
    field :cover_size, :integer
    field :file_url, :string
    field :file_name, :string
    field :file_type, :string
    field :file_size, :integer
    field :length, :integer, default: 0
    field :play_count, :integer, default: 0

    timestamps()
  end

  @changeset_attrs ~w(aired_date title description hosts slug cover_url cover_name cover_type cover_size file_url file_name file_type file_size length)a

  def changeset(episode, attrs) do
    episode
    |> cast(attrs, @changeset_attrs)
    |> validate_required(@changeset_attrs)
  end
end
