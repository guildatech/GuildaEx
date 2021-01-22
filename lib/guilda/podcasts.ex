defmodule Guilda.Podcasts do
  alias Guilda.Repo
  alias Guilda.Podcasts.Episode

  def list_podcast_episodes do
    Repo.all(Episode)
  end

  def create_episode(attrs \\ %{}) do
    %Episode{}
    |> Episode.changeset(attrs)
    |> Repo.insert()
  end

  def change_episode(%Episode{} = episode, attrs \\ %{}) do
    Episode.changeset(episode, attrs)
  end
end
