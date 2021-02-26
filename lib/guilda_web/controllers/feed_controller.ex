defmodule GuildaWeb.FeedController do
  use GuildaWeb, :controller

  alias Guilda.Podcasts

  def index(conn, _params) do
    render(conn, "index.xml", episodes: Podcasts.list_podcast_episodes())
  end
end
