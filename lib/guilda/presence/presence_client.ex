defmodule Guilda.PresenceClient do
  @moduledoc """
  A module to track and untrack metas to a given topic.
  """
  @behaviour Phoenix.Presence.Client

  @presence GuildaWeb.Presence
  @pubsub Guilda.PubSub

  alias Phoenix.Presence.Client

  def track(current_user_id) do
    Client.track(
      "proxy:" <> topic(),
      current_user_id,
      %{}
    )
  end

  def untrack(current_user_id) do
    Client.untrack(
      "proxy:" <> topic(),
      current_user_id
    )
  end

  def subscribe_to_online_users do
    Phoenix.PubSub.subscribe(@pubsub, topic())
  end

  def list(topic) do
    @presence.list("proxy:" <> topic)
  end

  @impl Phoenix.Presence.Client
  def init(_opts) do
    # user-land state
    {:ok, %{}}
  end

  @impl Phoenix.Presence.Client
  def handle_join(topic, _key, presence, state) do
    broadcast(topic, {__MODULE__, %{user_joined: presence}})
    {:ok, state}
  end

  @impl Phoenix.Presence.Client
  def handle_leave(topic, _key, presence, state) do
    broadcast(topic, {__MODULE__, %{user_left: presence}})
    {:ok, state}
  end

  defp topic do
    "online_users"
  end

  defp broadcast("proxy:" <> topic, payload) do
    Phoenix.PubSub.broadcast(@pubsub, topic, payload)
  end
end
