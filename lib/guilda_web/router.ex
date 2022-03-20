defmodule GuildaWeb.Router do
  use GuildaWeb, :router

  import GuildaWeb.UserAuth

  alias GuildaWeb.MountHooks

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {GuildaWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :fetch_current_user

    plug :put_secure_browser_headers, %{
      "content-security-policy" => ~w[
          'self'
          'unsafe-inline'
          api.mapbox.com
          default-src
          guilda-tech.s3.amazonaws.com
          oauth.telegram.org
          plausible.io
          rsms.me
          telegram.org
          unpkg.com
        ] |> Enum.join(" ")
    }
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :xml do
    plug :accepts, ["xml"]
    plug :put_layout, {GuildaWeb.LayoutView, :none}
    plug :put_resp_content_type, "application/xml"
  end

  scope "/", GuildaWeb do
    get "/podcast/feed.xml", FeedController, :index
  end

  live_session :default, on_mount: MountHooks.InitAssigns do
    scope "/", GuildaWeb do
      pipe_through [:browser]

      live "/", PageLive, :index

      live "/podcast", PodcastEpisodeLive.Index, :index
      live "/podcast/new", PodcastEpisodeLive.Index, :new
      live "/podcast/:id/edit", PodcastEpisodeLive.Index, :edit

      live "/members", MembersLive, :show

      ## Authentication routes
      get "/auth/telegram", AuthController, :telegram_callback
      delete "/users/log_out", UserSessionController, :delete
    end

    scope "/", GuildaWeb do
      pipe_through [:browser, :require_authenticated_user]

      get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

      live "/users/settings", UserSettingLive, :edit, as: :user_settings
      live "/finances", FinanceLive.Index, :index
      live "/finances/new", FinanceLive.Index, :new
      live "/finances/:id/edit", FinanceLive.Index, :edit
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", GuildaWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: GuildaWeb.Telemetry
    end
  end
end
