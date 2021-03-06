defmodule Guilda.Podcasts do
  @moduledoc """
  The Podcasts context.
  """

  import Ecto.Query, warn: false
  alias Guilda.Repo

  alias Guilda.Podcasts.Episode

  defdelegate authorize(action, user, params), to: Guilda.Podcasts.Policy

  @doc """
  Returns the most recent episode.

  ## Examples

      iex> most_recent_episode()
      %Episode{}

  """
  def most_recent_episode do
    from(e in Episode,
      order_by: [desc: :aired_date],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Returns the list of podcast_episodes.

  ## Examples

      iex> list_podcast_episodes()
      [%Episode{}, ...]

  """
  def list_podcast_episodes do
    from(e in Episode,
      order_by: [desc: :aired_date]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single episode.

  Raises `Ecto.NoResultsError` if the Episode does not exist.

  ## Examples

      iex> get_episode!(123)
      %Episode{}

      iex> get_episode!(456)
      ** (Ecto.NoResultsError)

  """
  def get_episode!(id), do: Repo.get!(Episode, id)

  @doc """
  Wraps create_episode/2 in a Bodyguard call. Runs the function
  if the user is authorized to perform the action.
  """
  def create_episode(user, attrs, after_save) do
    case Bodyguard.permit(__MODULE__, :create_episode, user) do
      :ok ->
        create_episode(attrs, after_save)

      other ->
        other
    end
  end

  @doc """
  Creates a episode.

  ## Examples

      iex> create_episode(%{field: value})
      {:ok, %Episode{}}

      iex> create_episode(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_episode(attrs, after_save \\ &{:ok, &1}) do
    %Episode{}
    |> Episode.changeset(attrs)
    |> Repo.insert()
    |> after_save(after_save)
  end

  defp after_save({:ok, episode}, func) do
    {:ok, _episode} = func.(episode)
  end

  defp after_save(error, _func), do: error

  @doc """
  Wraps update_episode/3 in a Bodyguard call. Runs the function
  if the user is authorized to perform the action.
  """
  def update_episode(user, %Episode{} = episode, attrs, after_save) do
    case Bodyguard.permit(__MODULE__, :update_episode, user) do
      :ok ->
        update_episode(episode, attrs, after_save)

      other ->
        other
    end
  end

  @doc """
  Updates a episode.

  ## Examples

      iex> update_episode(episode, %{field: new_value})
      {:ok, %Episode{}}

      iex> update_episode(episode, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_episode(%Episode{} = episode, attrs, after_save \\ &{:ok, &1}) do
    episode
    |> Episode.changeset(attrs)
    |> Repo.update()
    |> after_save(after_save)
  end

  @doc """
  Wraps delete_episode/1 in a Bodyguard call. Runs the function
  if the user is authorized to perform the action.
  """
  def delete_episode(user, %Episode{} = episode) do
    case Bodyguard.permit(__MODULE__, :delete_episode, user) do
      :ok ->
        delete_episode(episode)

      other ->
        other
    end
  end

  @doc """
  Deletes a episode.

  ## Examples

      iex> delete_episode(episode)
      {:ok, %Episode{}}

      iex> delete_episode(episode)
      {:error, %Ecto.Changeset{}}

  """
  def delete_episode(%Episode{} = episode) do
    Repo.delete(episode)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking episode changes.

  ## Examples

      iex> change_episode(episode)
      %Ecto.Changeset{data: %Episode{}}

  """
  def change_episode(%Episode{} = episode, attrs \\ %{}) do
    Episode.changeset(episode, attrs)
  end

  @doc """
  Increases the play count for an episode.
  """
  def increase_play_count(%Episode{} = episode) do
    from(e in Episode, update: [inc: [play_count: 1]], where: e.id == ^episode.id)
    |> Repo.update_all([])
  end

  @doc """
  Indicates if an episode should be marked as viewed.

  If the seconds played are equal or greater than 20% of the episode length it returns true.
  Returns false otherwise.

  ## Examples

      iex> should_mark_as_viewed(%Episode{length: 10}, 2)
      true

      iex> should_mark_as_viewed(%Episode{length: 10}, 1)
      false
  """
  def should_mark_as_viewed?(%Episode{length: length}, seconds_played_so_far) do
    seconds_played_so_far / length >= 0.2
  end
end
