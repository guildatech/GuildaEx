defmodule Guilda.MixProject do
  use Mix.Project

  def project do
    [
      app: :guilda,
      version: version(),
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        ignore_warnings: ".dialyzer_ignore.exs",
        plt_add_apps: [:ex_unit]
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        quality: :test
      ],
      homepage_url: "https://guildatech.com",
      name: "GuildaTech"
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Guilda.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 2.0"},
      {:bodyguard, "~> 2.4"},
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:distillery, "~> 2.0", warn_missing: false},
      {:ecto_sql, "~> 3.4"},
      {:err, "~> 0.1.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:ex_aws, "~> 2.0"},
      {:ex_machina, "~> 2.4"},
      {:ex_unit_notifier, "~> 1.0", only: :test},
      {:excoveralls, "~> 0.12"},
      {:floki, "~> 0.32.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:norm, git: "https://github.com/keathley/norm.git"},
      {:phoenix_ecto, "~> 4.1"},
      {:phoenix_html, "~> 3.1.0"},
      {:phoenix_live_dashboard, "~> 0.6.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.17.5"},
      {:phoenix, "~> 1.6.2", override: true},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:sobelow, "~> 0.9", only: [:dev, :test], runtime: false},
      {:stream_data, "~> 0.5.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 1.0.0"},
      {:timex, "~> 3.6"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      citest: ["ecto.create --quiet", "ecto.migrate", "run priv/repo/seeds.exs", "test"],
      quality: [
        "compile --force --all-warnings --warnings-as-errors",
        "test",
        "format",
        "credo --strict",
        "sobelow --config",
        "dialyzer --ignore-exit-status"
      ]
    ]
  end

  defp version do
    case System.cmd(
           "git",
           ~w[describe --dirty=+dirty],
           stderr_to_stdout: true
         ) do
      {version, 0} ->
        version
        |> String.replace_prefix("v", "")
        |> String.trim()
        |> Version.parse()
        |> bump_version()
        |> to_string()

      _ ->
        "0.0.0-dev"
    end
  end

  defp bump_version({:ok, %Version{pre: []} = version}), do: version

  defp bump_version({:ok, %Version{patch: p} = version}),
    do: struct(version, patch: p + 1)
end
