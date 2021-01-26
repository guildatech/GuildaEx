defmodule Guilda.Repo.Migrations.CreatePodcastEpisodes do
  use Ecto.Migration

  def change do
    create table(:podcast_episodes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :slug, :string, null: false
      add :description, :text, null: false
      add :aired_date, :date, null: false
      add :hosts, :string, null: false
      add :cover_url, :string, null: false
      add :cover_name, :string, null: false
      add :cover_type, :string, null: false
      add :cover_size, :integer, null: false
      add :file_url, :string, null: false
      add :file_name, :string, null: false
      add :file_type, :string, null: false
      add :file_size, :integer, null: false
      add :length, :integer, default: 0
      add :play_count, :integer, default: 0

      timestamps()
    end
  end
end
