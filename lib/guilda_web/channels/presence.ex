defmodule GuildaWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :guilda,
    pubsub_server: Guilda.PubSub,
    presence: __MODULE__

  @pubsub Guilda.PubSub

  def track_user(current_user_id) do
    track(
      self(),
      "proxy:" <> topic(),
      current_user_id,
      %{}
    )
  end

  def untrack_user(current_user_id) do
    untrack(
      self(),
      "proxy:" <> topic(),
      current_user_id
    )
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    for {user_id, presence} <- joins do
      user_data = %{user: presence.user, metas: Map.fetch!(presences, user_id)}
      broadcast(topic, {__MODULE__, %{user_joined: user_data}})
    end

    for {user_id, presence} <- leaves do
      metas =
        case Map.fetch(presences, user_id) do
          {:ok, presence_metas} -> presence_metas
          :error -> []
        end

      user_data = %{user: presence.user, metas: metas}

      broadcast(topic, {__MODULE__, %{user_left: user_data}})
    end

    {:ok, state}
  end

  def subscribe_to_online_users do
    Phoenix.PubSub.subscribe(@pubsub, "proxy:" <> topic())
  end

  def list_users(topic) do
    list("proxy:" <> topic)
  end

  def fetch(_topic, presences) do
    for {key, %{metas: metas}} <- presences, into: %{} do
      {key, %{metas: metas, user: key}}
    end
  end

  defp topic do
    "online_users"
  end

  defp broadcast("proxy:" <> topic, payload) do
    Phoenix.PubSub.broadcast(@pubsub, topic, payload)
  end
end
