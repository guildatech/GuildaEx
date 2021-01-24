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
      description: "some description",
      hosts: "some hosts",
      aired_date: "2020-01-01",
      cover_url: "some cover url",
      cover_name: "some cover name",
      cover_type: "some cover type",
      cover_size: 42,
      file_url: "some file url",
      file_name: "some file name",
      file_type: "some file type",
      file_size: 42,
      length: 42,
      play_count: 42
    }
  end
end
