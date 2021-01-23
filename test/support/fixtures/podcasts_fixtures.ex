defmodule Guilda.PodcastsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Guilda.Podcasts` context.
  """

  use ExMachina.Ecto, repo: Guilda.Repo

  def episode_factory do
    %Guilda.Podcasts.Episode{
      title: "some title",
      slug: "some slug",
      cover_url: "some cover",
      file_url: "some path",
      length: 42,
      play_count: 42
    }
  end
end