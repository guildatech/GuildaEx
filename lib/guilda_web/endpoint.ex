defmodule GuildaWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :guilda

  def init(_key, config) do
    if config[:load_from_system_env] do
      port = System.fetch_env!("PORT")
      secret_key_base = System.fetch_env!("SECRET_KEY_BASE")
      app_host = System.fetch_env!("APP_HOST")

      config =
        config
        |> Keyword.put(:http, [:inet6, port: port])
        |> Keyword.put(:secret_key_base, secret_key_base)
        |> Keyword.put(:url, host: app_host, scheme: "https", port: 443)

      {:ok, config}
    else
      {:ok, config}
    end
  end

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_guilda_key",
    signing_salt: "JIeS5L0B",
    same_site: "Strict"
  ]

  socket "/socket", GuildaWeb.UserSocket,
    websocket: true,
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :guilda,
    gzip: false,
    only: ~w(css js fonts images favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :guilda
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug GuildaWeb.Router
end
