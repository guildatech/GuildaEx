defmodule Guilda.Podcasts.Episode do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "podcast_episodes" do
    field :cover, :string
    field :path, :string
    field :length, :integer
    field :play_count, :integer
    field :tags, {:array, :string}

    timestamps()
  end

  def changeset(episode, attrs) do
    episode
    |> cast(attrs, [:cover, :path, :length, :play_count, :tags])
    |> validate_required([:cover, :path])
  end
end
