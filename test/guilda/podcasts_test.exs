defmodule Guilda.PodcastsTest do
  use Guilda.DataCase

  alias Guilda.Podcasts
  alias Guilda.Podcasts.Episode

  describe "episodes" do
    @valid_attrs %{cover: "some cover", path: "some path", length: 42, play_count: 42, tags: []}
    @invalid_attrs %{cover: nil, path: nil, length: nil, play_count: nil, tags: []}

    test "create_episode/1 with valid adata creates an episode" do
      assert {:ok, %Episode{} = episode} = Podcasts.create_episode(@valid_attrs)
      assert episode.cover == "some cover"
      assert episode.path == "some path"
      assert episode.length == 42
      assert episode.play_count == 42
      assert episode.tags == []
    end

    test "create_episode/1 with invalid data returns an error changeset" do
      assert {:error, %Ecto.Changeset{}} = Podcasts.create_episode(@invalid_attrs)
    end
  end
end
