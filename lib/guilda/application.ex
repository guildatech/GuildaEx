defmodule Guilda.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Guilda.Repo,
      # Start the Telemetry supervisor
      GuildaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Guilda.PubSub},
      # Start presence
      GuildaWeb.Presence,
      {Phoenix.Presence.Client,
       client: Guilda.PresenceClient, pubsub: Guilda.PubSub, presence: GuildaWeb.Presence, name: PresenceClient},
      # Start the Endpoint (http/https)
      GuildaWeb.Endpoint,
      # Start a worker by calling: Guilda.Worker.start_link(arg)
      # {Guilda.Worker, arg}
      # {Guilda.Bot, guilda_bot_config()}
      ExGram,
      {Guilda.Bot, guilda_bot_config()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Guilda.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GuildaWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  if Application.get_env(:guilda, :environment) == :test do
    def guilda_bot_config do
      [method: :noup, token: "token"]
    end
  else
    def guilda_bot_config do
      [method: :polling, token: Application.fetch_env!(:guilda, :auth)[:telegram_bot_token]]
    end
  end
end
