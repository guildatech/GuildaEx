defmodule Guilda.Podcasts.Episode do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "podcast_episodes" do
    field :title, :string
    field :slug, :string
    field :cover_url, :string
    field :file_url, :string
    field :length, :integer, default: 0
    field :play_count, :integer, default: 0

    timestamps()
  end

  def changeset(episode, attrs) do
    episode
    |> cast(attrs, [:title, :cover_url, :file_url, :length, :slug])
    |> validate_required([:title, :cover_url, :file_url, :length, :slug])
  end
end
