defmodule Guilda.Repo.Migrations.CreatePodcastEpisodes do
  use Ecto.Migration

  def change do
    create table(:podcast_episodes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :cover, :string
      add :path, :string
      add :length, :integer
      add :play_count, :integer
      add :tags, {:array, :string}

      timestamps()
    end
  end
end
