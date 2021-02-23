defmodule GuildaWeb.Router do
  use GuildaWeb, :router

  import GuildaWeb.UserAuth

  @content_security_policy %{
    "default-src" => ~w[
      'self'
      http://guilda-tech.s3.amazonaws.com
      https://guilda-tech.s3.amazonaws.com
      https://telegram.org
      https://oauth.telegram.org
    ],
    "connect-src" => ~w[
      ws://localhost:*
      wss://localhost:*
      http://localhost:*
      http://guildatech.com
      https://guildatech.com
      ws://guildatech.com
      wss://guildatech.com
      http://guilda-tech.s3.amazonaws.com
      https://guilda-tech.s3.amazonaws.com
      *.plausible.io
      plausible.io
    ],
    "script-src" => ~w[
      'self'
      'unsafe-inline'
      'unsafe-eval'
      https://telegram.org
      *.plausible.io
      plausible.io
    ],
    "style-src" => ~w[
      'self'
      'unsafe-inline'
      https://rsms.me
    ],
    "font-src" => ~w[
      'self'
      https://rsms.me
    ]
  }

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {GuildaWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :fetch_current_user

    plug :put_secure_browser_headers, %{
      "content-security-policy" =>
        Enum.map_join(@content_security_policy, " ", fn {k, v} -> "#{k} #{Enum.join(v, " ")};" end)
    }
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GuildaWeb do
    pipe_through [:browser]

    live "/", PageLive, :index

    live "/podcast", PodcastEpisodeLive.Index, :index
    live "/podcast/new", PodcastEpisodeLive.Index, :new
    live "/podcast/:id/edit", PodcastEpisodeLive.Index, :edit

    ## Authentication routes
    get "/auth/telegram", AuthController, :telegram_callback
    delete "/users/log_out", UserSessionController, :delete
  end

  scope "/", GuildaWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/users/settings", UserSettingLive, :edit, as: :user_settings
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

    live "/finances", FinanceLive.Index, :index
    live "/finances/new", FinanceLive.Index, :new
    live "/finances/:id/edit", FinanceLive.Index, :edit
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
