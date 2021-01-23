defmodule Guilda.Repo.Migrations.CreatePodcastEpisodes do
  use Ecto.Migration

  def change do
    create table(:podcast_episodes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :slug, :string, null: false
      add :cover_url, :string
      add :cover_name, :string
      add :cover_type, :string
      add :cover_size, :integer
      add :file_url, :string
      add :file_name, :string
      add :file_type, :string
      add :file_size, :integer
      add :length, :integer, default: 0
      add :play_count, :integer, default: 0

      timestamps()
    end
  end
end
