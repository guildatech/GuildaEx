defmodule Guilda.PodcastsTest do
  use Guilda.DataCase

  alias Guilda.Podcasts
  alias Guilda.Podcasts.Episode
  import Guilda.PodcastsFixtures

  describe "episodes" do
    test "list_episodes/0 returns all episodes" do
      episode = insert(:episode)
      assert Podcasts.list_podcast_episodes() == [episode]
    end

    test "get_episode!/1 returns the episode with given id" do
      episode = insert(:episode)
      assert Podcasts.get_episode!(episode.id) == episode
    end

    test "create_episode/1 with valid adata creates an episode" do
      assert {:ok, %Episode{}} = Podcasts.create_episode(params_for(:episode))
    end

    test "create_episode/1 with invalid data returns an error changeset" do
      assert {:error, %Ecto.Changeset{}} = Podcasts.create_episode(params_for(:episode, %{title: ""}))
    end

    test "update_episode/2 with invalid data returns error changeset" do
      episode = insert(:episode)
      assert {:error, %Ecto.Changeset{}} = Podcasts.update_episode(episode, params_for(:episode, %{title: ""}))
      assert episode == Podcasts.get_episode!(episode.id)
    end

    test "delete_episode/1 deletes the episode" do
      episode = insert(:episode)
      assert {:ok, %Episode{}} = Podcasts.delete_episode(episode)
      assert_raise Ecto.NoResultsError, fn -> Podcasts.get_episode!(episode.id) end
    end

    test "change_episode/1 returns a episode changeset" do
      episode = insert(:episode)
      assert %Ecto.Changeset{} = Podcasts.change_episode(episode)
    end

    test "increase_play_count/1" do
      episode = insert(:episode)
      assert {1, nil} = Podcasts.increase_play_count(episode)
      assert Podcasts.get_episode!(episode.id).play_count == episode.play_count + 1
    end

    test "should_mark_as_viewed?/2" do
      assert Podcasts.should_mark_as_viewed?(%Episode{length: 10}, 3)
      assert Podcasts.should_mark_as_viewed?(%Episode{length: 10}, 2)
      refute Podcasts.should_mark_as_viewed?(%Episode{length: 10}, 1)
      refute Podcasts.should_mark_as_viewed?(%Episode{length: 10}, 0)
    end
  end
end
